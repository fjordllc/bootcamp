# frozen_string_literal: true

require 'test_helper'

class McpAuthorizationTest < ActionDispatch::IntegrationTest
  RESOURCE = 'http://www.example.com/mcp'
  SCOPE = 'mcp:practices:read'
  CALLBACK = 'http://127.0.0.1:48321/callback'
  VERIFIER = 'dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk'
  CHALLENGE = Base64.urlsafe_encode64(Digest::SHA256.digest(VERIFIER), padding: false)

  setup do
    @previous_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rails.cache = @previous_cache
  end

  test 'mentor and admin-only users may initialize while adviser, student, trainee, and graduate are forbidden' do
    %i[mentormentaro adminonly].each do |fixture_name|
      post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(create_mcp_token(users(fixture_name)))
      assert_response :ok, fixture_name.to_s
    end

    %i[advijirou kimura kensyu sotugyou].each do |fixture_name|
      post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(create_mcp_token(users(fixture_name)))
      assert_response :forbidden, fixture_name.to_s
    end
  end

  test 'each inactive state blocks a previously valid mentor token' do
    mentor = users(:mentormentaro)
    token = create_mcp_token(mentor)

    [
      { hibernated_at: Time.current },
      { training_completed_at: Time.current },
      { retired_on: Date.current }
    ].each do |inactive_attributes|
      mentor.update!(inactive_attributes)
      post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)
      assert_response :forbidden, inactive_attributes.keys.first.to_s
      mentor.update!(hibernated_at: nil, training_completed_at: nil, retired_on: nil)
    end
  end

  test 'each inactive state also blocks an admin-only user' do
    admin = users(:adminonly)
    token = create_mcp_token(admin)

    [
      { hibernated_at: Time.current },
      { training_completed_at: Time.current },
      { retired_on: Date.current }
    ].each do |inactive_attributes|
      admin.update!(inactive_attributes)
      post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)
      assert_response :forbidden, inactive_attributes.keys.first.to_s
      admin.update!(hibernated_at: nil, training_completed_at: nil, retired_on: nil)
    end
  end

  test 'invalid, revoked, and insufficient-scope tokens are rejected with the correct status' do
    post '/mcp', params: initialize_request, as: :json, headers: mcp_headers_for_value('not-a-token')
    assert_response :unauthorized

    token = create_mcp_token
    token.revoke
    post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)
    assert_response :unauthorized

    token = create_mcp_token(scopes: 'read')
    post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)
    assert_response :forbidden
  end

  test 'a token bound to another audience is forbidden' do
    token = create_mcp_token(resource: 'http://www.example.com/other')

    post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)

    assert_response :forbidden
  end

  test 'an admin cookie cannot elevate a student bearer token' do
    sign_in(users(:adminonly))
    token = create_mcp_token(users(:kimura))

    post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)

    assert_response :forbidden
  end

  test 'removing a mentor role or retiring the owner blocks an already issued token' do
    mentor = users(:mentormentaro)
    token = create_mcp_token(mentor)

    mentor.update!(mentor: false)
    post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)
    assert_response :forbidden

    mentor.update!(mentor: true, retired_on: Date.current)
    post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)
    assert_response :forbidden
  end

  test 'inactive users cannot authorize on either the authorization GET or POST' do
    application = create_mcp_application
    mentor = users(:mentormentaro)
    sign_in(mentor)
    mentor.update!(hibernated_at: Time.current)

    get '/oauth/authorize', params: authorization_params(application)
    assert_response :forbidden

    post '/oauth/authorize', params: authorization_params(application)
    assert_response :forbidden
  end

  test 'OAuth Basic client authentication does not bypass inactive-owner checks at token exchange' do
    application = create_mcp_application(confidential: true)
    mentor = users(:mentormentaro)
    grant = create_mcp_grant(application, mentor)
    mentor.update!(training_completed_at: Time.current)

    post '/oauth/token',
         params: token_params(application, grant.token).except(:client_id),
         headers: { 'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials(application.uid, application.secret) }

    assert_response :forbidden
    assert_not grant.reload.revoked?
  end

  test 'OAuth Basic client authentication does not bypass resource validation at token exchange' do
    application = create_mcp_application(confidential: true)
    grant = create_mcp_grant(application, users(:mentormentaro))

    post '/oauth/token',
         params: token_params(application, grant.token).except(:client_id).merge(resource: 'http://www.example.com/other'),
         headers: { 'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials(application.uid, application.secret) }

    assert_response :bad_request
    assert_equal 'invalid_target', response.parsed_body.fetch('error')
    assert_not grant.reload.revoked?
  end

  test 'MCP authorization rejects absent and plain PKCE challenges' do
    application = create_mcp_application
    sign_in(users(:mentormentaro))

    get '/oauth/authorize', params: authorization_params(application).except(:code_challenge, :code_challenge_method)
    assert_response :bad_request
    assert_equal 'invalid_request', response.parsed_body.fetch('error')

    get '/oauth/authorize', params: authorization_params(application, code_challenge_method: 'plain')
    assert_response :bad_request
    assert_equal 'invalid_request', response.parsed_body.fetch('error')
  end

  test 'an access token without an owner is forbidden at the MCP HTTP boundary' do
    token = create_mcp_token
    token.update!(resource_owner_id: nil)

    post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)

    assert_response :forbidden
  end

  test 'loopback redirect URIs may use a different port through authorization and token exchange' do
    %w[localhost 127.0.0.1 [::1]].each do |host|
      registered = "http://#{host}:48321/callback"
      requested = "http://#{host}:49321/callback"
      application = create_mcp_application(redirect_uri: registered)
      mentor = users(:mentormentaro)
      sign_in(mentor)

      get '/oauth/authorize', params: authorization_params(application, redirect_uri: requested)
      assert_response :ok, host

      post '/oauth/authorize', params: authorization_params(application, redirect_uri: requested)
      assert_response :redirect, host
      code = Rack::Utils.parse_query(URI.parse(response.location).query).fetch('code')
      assert response.location.start_with?(requested), host

      post '/oauth/token', params: token_params(application, code).merge(redirect_uri: registered)
      assert_response :bad_request, host

      post '/oauth/token', params: token_params(application, code).merge(redirect_uri: requested)
      assert_response :ok, host
      assert response.parsed_body.fetch('access_token').present?, host
    end
  end

  test 'loopback redirect URIs with a different path or host are rejected at authorization' do
    application = create_mcp_application(redirect_uri: 'http://localhost:48321/callback')
    sign_in(users(:mentormentaro))

    %w[http://localhost:49321/other http://127.0.0.1:49321/callback https://localhost:49321/callback].each do |uri|
      get '/oauth/authorize', params: authorization_params(application, redirect_uri: uri)
      assert_response :bad_request, uri
    end
  end

  test 'non-MCP clients keep exact localhost redirect URI matching' do
    application = Doorkeeper::Application.create!(
      name: 'Regular client', redirect_uri: 'http://localhost:48321/callback', scopes: 'read', confidential: false
    )
    sign_in(users(:mentormentaro))

    get '/oauth/authorize', params: {
      client_id: application.uid, redirect_uri: 'http://localhost:49321/callback', response_type: 'code', scope: 'read'
    }
    assert_response :bad_request
  end

  private

  def initialize_request
    {
      jsonrpc: '2.0',
      id: 1,
      method: 'initialize',
      params: {
        protocolVersion: '2025-11-25',
        capabilities: {},
        clientInfo: { name: 'test-client', version: '1.0' }
      }
    }
  end

  def create_mcp_application(confidential: false, redirect_uri: CALLBACK)
    Doorkeeper::Application.create!(
      name: 'MCP authorization matrix client',
      redirect_uri:,
      scopes: SCOPE,
      confidential:,
      mcp_client: true
    )
  end

  def create_mcp_token(user = users(:mentormentaro), scopes: SCOPE, resource: RESOURCE)
    Doorkeeper::AccessToken.create!(
      application: create_mcp_application,
      resource_owner_id: user.id,
      token: SecureRandom.hex(32),
      scopes:,
      resource:,
      expires_in: 3600
    )
  end

  def create_mcp_grant(application, user)
    Doorkeeper::AccessGrant.create!(
      application:,
      resource_owner_id: user.id,
      token: SecureRandom.hex(32),
      expires_in: 600,
      redirect_uri: CALLBACK,
      scopes: SCOPE,
      resource: RESOURCE,
      code_challenge: CHALLENGE,
      code_challenge_method: 'S256'
    )
  end

  def mcp_headers(token)
    mcp_headers_for_value(token.token)
  end

  def mcp_headers_for_value(value)
    { 'Authorization' => "Bearer #{value}", 'Accept' => 'application/json, text/event-stream' }
  end

  def authorization_params(application, **overrides)
    {
      client_id: application.uid,
      redirect_uri: CALLBACK,
      response_type: 'code',
      scope: SCOPE,
      state: 'test-state',
      resource: RESOURCE,
      code_challenge: CHALLENGE,
      code_challenge_method: 'S256'
    }.merge(overrides)
  end

  def token_params(application, code)
    {
      grant_type: 'authorization_code',
      client_id: application.uid,
      code:,
      redirect_uri: CALLBACK,
      resource: RESOURCE,
      code_verifier: VERIFIER
    }
  end
end
