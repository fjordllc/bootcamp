# frozen_string_literal: true

require 'test_helper'

class OauthAuthorizationsTest < ActionDispatch::IntegrationTest
  setup do
    @application = Doorkeeper::Application.create!(
      name: 'OAuth authorization test',
      redirect_uri: 'https://example.invalid/callback',
      scopes: 'read write'
    )
    sign_in(:kimura)
  end

  test 'native authorization displays the issued code without consent forms' do
    @application.update!(redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')

    assert_difference('Doorkeeper::AccessGrant.count') do
      post oauth_authorization_path, params: authorization_params
    end
    assert_response :redirect
    follow_redirect!

    assert_response :ok
    assert_select '#authorization_code', text: Doorkeeper::AccessGrant.last.token
    assert_no_consent_forms
  end

  test 'invalid client displays the OAuth error without consent forms' do
    get oauth_authorization_path, params: authorization_params.merge(client_id: 'unknown-client')

    assert_oauth_error(:unauthorized, 'invalid_client')
  end

  test 'invalid redirect URI displays the OAuth error without consent forms' do
    get oauth_authorization_path, params: authorization_params.merge(redirect_uri: 'https://other.example.invalid/callback')

    assert_oauth_error(:bad_request, 'invalid_redirect_uri')
  end

  test 'invalid scope displays the OAuth error without consent forms' do
    get oauth_authorization_path, params: authorization_params.merge(scope: 'unknown-scope')

    assert_oauth_error(:bad_request, 'invalid_scope')
  end

  test 'valid authorization displays permissions and both forms with all request parameters' do
    params = authorization_params.merge(code_challenge: 'a' * 43, code_challenge_method: 'S256', response_mode: 'query')

    get oauth_authorization_path, params: params

    assert_response :ok
    assert_select '#oauth-permissions', count: 1 do
      %w[read write].each do |scope|
        assert_select 'li', text: I18n.t("doorkeeper.scopes.#{scope}"), count: 1
      end
    end
    assert_select "form[action='#{oauth_authorization_path}'][method='post']", count: 2 do |forms|
      forms.each do |form|
        params.each do |name, value|
          assert_select form, "input[type='hidden'][name='#{name}'][value='#{value}']", count: 1
        end
      end
    end
    assert_select "input[name='_method'][value='delete']", count: 1
    assert_select "input[type='submit'][value='#{I18n.t('doorkeeper.authorizations.buttons.authorize')}']", count: 1
    assert_select "input[type='submit'][value='#{I18n.t('doorkeeper.authorizations.buttons.deny')}']", count: 1
  end

  private

  def authorization_params
    {
      client_id: @application.uid,
      redirect_uri: @application.redirect_uri,
      response_type: 'code',
      scope: 'read write',
      state: 'oauth-test-state'
    }
  end

  def assert_oauth_error(status, error)
    assert_response status
    assert_select 'pre', text: /#{Regexp.escape(I18n.t("doorkeeper.errors.messages.#{error}"))}/
    assert_no_consent_forms
  end

  def assert_no_consent_forms
    assert_select '#oauth-permissions', count: 0
    assert_select "form[action='#{oauth_authorization_path}']", count: 0
  end
end
