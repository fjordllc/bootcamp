# frozen_string_literal: true

require 'test_helper'

class OauthLoginReturnTest < ActionDispatch::IntegrationTest
  setup do
    @application = Doorkeeper::Application.create!(
      name: 'OAuth login return test',
      redirect_uri: 'https://example.invalid/callback',
      scopes: 'read'
    )
  end

  test 'returns to the authorization request after logging in' do
    get oauth_authorization_path, params: authorization_params
    assert_redirected_to login_path
    authorization_url = request.fullpath

    post user_sessions_path, params: { user: { login: 'kimura', password: 'testtest' } }

    assert_redirected_to authorization_url
    follow_redirect!
    assert_response :ok
    assert_select "form[action='#{oauth_authorization_path}']"
  end

  test 'returns to the authorization request after logging in following a wrong password' do
    get oauth_authorization_path, params: authorization_params
    assert_redirected_to login_path
    authorization_url = request.fullpath

    post user_sessions_path, params: { user: { login: 'kimura', password: 'wrong-password' } }
    assert_response :ok
    post user_sessions_path, params: { user: { login: 'kimura', password: 'testtest' } }

    assert_redirected_to authorization_url
  end

  test 'shows the authorization request without the login page when already logged in' do
    post user_sessions_path, params: { user: { login: 'kimura', password: 'testtest' } }

    get oauth_authorization_path, params: authorization_params

    assert_response :ok
    assert_select "form[action='#{oauth_authorization_path}']"
  end

  test 'returns to the authorization request after logging in with GitHub' do
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:github, { uid: '12345', info: { name: 'kimura' } })
    users(:kimura).update!(github_id: '12345')

    get oauth_authorization_path, params: authorization_params
    assert_redirected_to login_path
    authorization_url = request.fullpath

    get '/auth/github/callback'

    assert_redirected_to authorization_url
  ensure
    OmniAuth.config.mock_auth[:github] = nil
    OmniAuth.config.test_mode = false
  end

  test 'goes to the login page without storing an authorization request too long for the session cookie' do
    get oauth_authorization_path, params: authorization_params.merge(state: 'a' * 3000)

    assert_redirected_to login_path
    assert_nil session[:return_to_url]

    post user_sessions_path, params: { user: { login: 'kimura', password: 'testtest' } }

    assert_redirected_to root_url
  end

  test 'does not return to an earlier authorization request after one too long for the session cookie' do
    get oauth_authorization_path, params: authorization_params
    assert_redirected_to login_path
    assert_not_nil session[:return_to_url]

    get oauth_authorization_path, params: authorization_params.merge(state: 'a' * 3000)
    assert_redirected_to login_path
    assert_nil session[:return_to_url]

    post user_sessions_path, params: { user: { login: 'kimura', password: 'testtest' } }

    assert_redirected_to root_url
  end

  private

  def authorization_params
    {
      client_id: @application.uid,
      redirect_uri: @application.redirect_uri,
      response_type: 'code',
      scope: 'read',
      state: 'oauth-login-return-test-state'
    }
  end
end
