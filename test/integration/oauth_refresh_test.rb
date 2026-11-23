# frozen_string_literal: true

require 'test_helper'

class OAuthRefreshTest < ActionDispatch::IntegrationTest
  setup do
    @previous_refresh_client_uid = ENV.fetch('BOOTCAMP_REFRESH_CLIENT_UID', nil)
    @application = Doorkeeper::Application.create!(name: 'Classroom refresh test', redirect_uri: 'https://example.invalid/callback', scopes: 'read')
    ENV['BOOTCAMP_REFRESH_CLIENT_UID'] = @application.uid
  end

  teardown do
    ENV['BOOTCAMP_REFRESH_CLIENT_UID'] = @previous_refresh_client_uid
  end

  test 'opted-in confidential read authorization code issues renewable bounded tokens' do
    original = exchange_code
    assert original['refresh_token'].present?
    assert_equal 7200, original['expires_in']
    assert_equal 'read', original['scope']

    travel 7201.seconds do
      refresh(original['refresh_token'])
      assert_response :ok
      replacement = response.parsed_body
      assert replacement['refresh_token'].present?
      assert_not_equal original['refresh_token'], replacement['refresh_token']
      assert_equal 7200, replacement['expires_in']
      assert_equal 'read', replacement['scope']

      get api_users_path(format: :json), headers: bearer_headers(replacement['access_token'])
      assert_response :ok
      token = Doorkeeper::AccessToken.by_token(replacement['access_token'])
      assert_equal users(:kimura).id, token.resource_owner_id
      assert_equal @application.id, token.application_id

      refresh(replacement['refresh_token'])
      assert_response :ok
      assert response.parsed_body['refresh_token'].present?
      assert_equal 'read', response.parsed_body['scope']
    end
  end

  test 'default unset and malformed or nonmatching opt-in never issue refresh tokens' do
    [nil, '', ' ', " #{@application.uid}", "#{@application.uid},another-client", 'another-client'].each do |uid|
      ENV['BOOTCAMP_REFRESH_CLIENT_UID'] = uid
      token = exchange_code
      assert_nil token['refresh_token']
      assert_equal 7200, token['expires_in']
      assert_equal 'read', token['scope']
    end
  end

  test 'public client never receives refresh tokens' do
    @application.update!(confidential: false)
    assert_nil exchange_code['refresh_token']
  end

  test 'MCP client never receives refresh tokens even when explicitly opted in with read scopes' do
    resource = 'http://www.example.com/mcp'
    verifier = 'dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk'
    challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)

    %w[read mcp:practices:read].each do |scopes|
      @application.update!(mcp_client: true, scopes:)
      grant = Doorkeeper::AccessGrant.create!(
        application: @application, resource_owner_id: users(:kimura).id,
        redirect_uri: @application.redirect_uri, scopes:, expires_in: 600,
        resource:, code_challenge: challenge, code_challenge_method: 'S256'
      )

      post oauth_token_path, params: client_credentials.merge(
        grant_type: 'authorization_code', code: grant.token, redirect_uri: @application.redirect_uri,
        resource:, code_verifier: verifier
      )

      assert_response :ok
      assert grant.reload.revoked?
      assert response.parsed_body['access_token'].present?
      assert_nil response.parsed_body['refresh_token']
      assert_equal resource, Doorkeeper::AccessToken.by_token(response.parsed_body['access_token']).resource
    end
  end

  test 'application and grant scopes must both be exactly read' do
    ['', 'write', 'read write', 'read mentor', 'read admin', 'read unknown'].each do |scopes|
      assert_nil exchange_code(scopes:)['refresh_token']
    end

    ['write', 'mentor', 'admin', 'read write', 'read mentor', 'read admin', 'read write mentor admin'].each do |scopes|
      @application.update!(scopes:)
      assert_nil exchange_code(scopes:)['refresh_token']
      assert_nil exchange_code(scopes: 'read')['refresh_token'] if scopes.start_with?('read ')
    end

    @application.update!(scopes: '')
    assert_nil exchange_code['refresh_token']
    assert_nil exchange_code(scopes: '')['refresh_token']
  end

  test 'client credentials does not receive refresh tokens or a resource owner' do
    post oauth_token_path, params: client_credentials.merge(grant_type: 'client_credentials', scope: 'read')
    assert_response :ok
    assert_nil response.parsed_body['refresh_token']
    assert_nil Doorkeeper::AccessToken.by_token(response.parsed_body['access_token']).resource_owner_id
  end

  test 'refresh rejects scope escalation and credentials for another client' do
    original = exchange_code
    assert original['refresh_token'].present?

    refresh(original['refresh_token'], scope: 'read write')
    assert_response :bad_request
    assert_equal 'invalid_scope', response.parsed_body['error']

    other = Doorkeeper::Application.create!(name: 'Other refresh test', redirect_uri: @application.redirect_uri, scopes: 'read')
    post oauth_token_path, params: { grant_type: 'refresh_token', refresh_token: original['refresh_token'], client_id: other.uid, client_secret: other.secret }
    assert_response :bad_request
    assert_equal 'invalid_grant', response.parsed_body['error']

    refresh(original['refresh_token'])
    assert_response :ok
    assert_equal 'read', response.parsed_body['scope']
  end

  test 'rotation revokes previous token only when replacement access token is used' do
    original = exchange_code
    assert original['refresh_token'].present?
    refresh(original['refresh_token'])
    assert_response :ok
    replacement = response.parsed_body
    previous = Doorkeeper::AccessToken.by_token(original['access_token'])
    assert_nil previous.reload.revoked_at

    # Doorkeeper 5.8.2 permits retrying the old refresh before first replacement use.
    refresh(original['refresh_token'])
    assert_response :ok

    get api_users_path(format: :json), headers: bearer_headers(replacement['access_token'])
    assert_response :ok
    assert previous.reload.revoked?

    refresh(original['refresh_token'])
    assert_response :bad_request
    assert_equal 'invalid_grant', response.parsed_body['error']
    get api_users_path(format: :json), headers: bearer_headers(original['access_token'])
    assert_response :unauthorized
  end

  test 'removing opt-in stops new issuance but existing refresh requires explicit revocation' do
    original = exchange_code
    assert original['refresh_token'].present?
    ENV.delete('BOOTCAMP_REFRESH_CLIENT_UID')
    assert_nil exchange_code['refresh_token']

    refresh(original['refresh_token'])
    assert_response :ok
    replacement = response.parsed_body
    assert replacement['refresh_token'].present?

    post oauth_revoke_path, params: client_credentials.merge(token: replacement['refresh_token'], token_type_hint: 'refresh_token')
    assert_response :ok
    assert Doorkeeper::AccessToken.by_token(replacement['access_token']).revoked?
    refresh(replacement['refresh_token'])
    assert_response :bad_request
    assert_equal 'invalid_grant', response.parsed_body['error']
  end

  test 'revocation with another client credentials cannot revoke the token' do
    original = exchange_code
    other = Doorkeeper::Application.create!(name: 'Other revocation test', redirect_uri: @application.redirect_uri, scopes: 'read')

    post oauth_revoke_path, params: {
      client_id: other.uid, client_secret: other.secret,
      token: original['refresh_token'], token_type_hint: 'refresh_token'
    }
    assert_response :forbidden
    assert_equal 'unauthorized_client', response.parsed_body['error']
    assert_not Doorkeeper::AccessToken.by_token(original['access_token']).revoked?

    refresh(original['refresh_token'])
    assert_response :ok
    assert_equal 'read', response.parsed_body['scope']
  end

  test 'revocation of an invalid token returns the standard success response without a session' do
    post oauth_revoke_path, params: client_credentials.merge(token: 'invalid-refresh-token', token_type_hint: 'refresh_token')

    assert_response :ok
    assert_empty response.parsed_body
  end

  private

  def exchange_code(scopes: 'read')
    grant = Doorkeeper::AccessGrant.create!(
      application: @application, resource_owner_id: users(:kimura).id,
      redirect_uri: @application.redirect_uri, scopes:, expires_in: 600
    )
    post oauth_token_path, params: client_credentials.merge(grant_type: 'authorization_code', code: grant.token, redirect_uri: @application.redirect_uri)
    assert_response :ok
    assert grant.reload.revoked?
    response.parsed_body
  end

  def refresh(token, **parameters)
    post oauth_token_path, params: client_credentials.merge(grant_type: 'refresh_token', refresh_token: token, **parameters)
  end

  def client_credentials
    { client_id: @application.uid, client_secret: @application.secret }
  end

  def bearer_headers(token)
    { 'Authorization' => "Bearer #{token}", 'Accept' => 'application/json' }
  end
end
