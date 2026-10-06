# frozen_string_literal: true

require 'test_helper'

class API::InactiveUserAuthorizationTest < ActionDispatch::IntegrationTest
  INACTIVE_ATTRIBUTES = %i[hibernated_at training_completed_at retired_on].freeze

  setup do
    @user = users(:kimura)
    @application = Doorkeeper::Application.create!(name: 'Login security test', redirect_uri: 'https://example.invalid/callback', scopes: 'read write')
  end

  INACTIVE_ATTRIBUTES.each do |attribute|
    test "#{attribute} prevents API token issuance and clears prior session" do
      sign_in(:komagata)
      @user.update!(attribute => Time.current)
      post api_session_path, params: { login_name: @user.login_name, password: 'testtest' }
      assert_response :bad_request
      assert_empty response.body
      get api_users_path(format: :json)
      assert_unauthorized
    end

    test "#{attribute} blocks a previously issued JWT and allows it again after reactivation" do
      token = create_token(@user.login_name, 'testtest')
      assert token.present?
      reset!
      headers = bearer_headers(token)
      get api_users_path(format: :json), headers: headers
      assert_response :ok

      @user.update!(attribute => Time.current)
      reset!
      get api_users_path(format: :json), headers: headers
      assert_unauthorized
      reset!
      assert_no_difference('Comment.count') { create_comment(headers) }
      assert_unauthorized

      @user.update!(attribute => nil)
      reset!
      get api_users_path(format: :json), headers: headers
      assert_response :ok
    end

    test "#{attribute} blocks a persisted session on each request" do
      sign_in(@user)
      get api_users_path(format: :json)
      assert_response :ok
      @user.update!(attribute => Time.current)
      get api_users_path(format: :json)
      assert_unauthorized
      assert_no_difference('Comment.count') { create_comment({}) }
      assert_unauthorized
    end

    test "#{attribute} blocks existing OAuth read and write tokens without revoking them" do
      token = oauth_token('read write')
      headers = bearer_headers(token.token)
      get api_users_path(format: :json), headers: headers
      assert_response :ok
      assert_difference('Comment.count') { create_comment(headers) }
      assert_response :created

      @user.update!(attribute => Time.current)
      reset!
      get api_users_path(format: :json), headers: headers
      assert_unauthorized
      assert_no_difference('Comment.count') { create_comment(headers) }
      assert_unauthorized
      assert_nil token.reload.revoked_at

      @user.update!(attribute => nil)
      reset!
      get api_users_path(format: :json), headers: headers
      assert_response :ok
      assert_difference('Comment.count') { create_comment(headers) }
      assert_response :created
    end

    test "#{attribute} OAuth owner cannot be masked by an active session" do
      token = oauth_token('read write')
      @user.update!(attribute => Time.current)
      sign_in(:komagata)
      headers = bearer_headers(token.token)
      get api_users_path(format: :json), headers: headers
      assert_unauthorized
      assert_no_difference('Comment.count') { create_comment(headers) }
      assert_unauthorized
    end

    test "#{attribute} stale session can log in to another active account through API session create" do
      sign_in(@user)
      @user.update!(attribute => Time.current)
      token = create_token('komagata', 'testtest')
      assert_response :ok
      assert token.present?
      reset!
      get api_users_path(format: :json), headers: bearer_headers(token)
      assert_response :ok
    end
  end

  test 'anonymous public tags remain accessible' do
    get api_tags_path(format: :json), params: { taggable_type: 'Question' }
    assert_response :ok
  end

  test 'active OAuth read token retains invalid scope response on write' do
    token = oauth_token('read')
    assert_no_difference('Comment.count') { create_comment(bearer_headers(token.token)) }
    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'web inactive alerts and comeback link remain unchanged' do
    { taikai: '退会したユーザーです。', kensyuowata: '研修終了したユーザーです。', kyuukai: '休会中です。' }.each do |fixture, message|
      sign_in(fixture)
      assert_response :ok
      assert_includes response.body, message
      assert_select "a[href='#{new_comeback_path}']" if fixture == :kyuukai
      get api_users_path(format: :json)
      assert_unauthorized
    end
  end

  private

  def oauth_token(scopes)
    Doorkeeper::AccessToken.create!(application: @application, resource_owner_id: @user.id, scopes:)
  end

  def bearer_headers(token)
    { 'Authorization' => "Bearer #{token}", 'Accept' => 'application/json' }
  end

  def create_comment(headers)
    post api_report_comments_path(reports(:report1), format: :json),
         params: { comment: { description: 'Synthetic login security comment' } }, headers: headers
  end

  def assert_unauthorized
    assert_response :unauthorized
    assert_equal({ 'error' => 'unauthorized' }, response.parsed_body)
    assert_equal 'application/json', response.media_type
    assert_nil response.headers['Location']
  end
end
