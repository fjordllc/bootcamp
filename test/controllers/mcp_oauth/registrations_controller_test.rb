# frozen_string_literal: true

require 'test_helper'

class McpOauth::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  PRACTICES_SCOPE = 'mcp:practices:read'
  RESOURCE = 'http://www.example.com/mcp'
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

  test 'DCR registers a public client with only the MCP scope' do
    post '/oauth/register', params: registration_params, as: :json

    assert_response :created
    body = response.parsed_body
    application = Doorkeeper::Application.find_by!(uid: body.fetch('client_id'))

    assert_not application.confidential
    assert_predicate application, :mcp_client?
    assert_equal PRACTICES_SCOPE, application.scopes.to_s
    assert_equal CALLBACK, application.redirect_uri
    assert_equal 'none', body.fetch('token_endpoint_auth_method')
    assert_equal ['authorization_code'], body.fetch('grant_types')
    assert_not body.key?('client_secret')
  end

  test 'DCR accepts a refresh token request but registers only the grant the server issues' do
    post '/oauth/register', params: registration_params(grant_types: %w[authorization_code refresh_token]), as: :json

    assert_response :created
    assert_equal ['authorization_code'], response.parsed_body.fetch('grant_types')
  end

  test 'DCR rejects non-loopback HTTP redirects, extra scopes, and confidential clients' do
    invalid_requests = [
      registration_params(redirect_uris: ['http://example.com/callback']),
      registration_params(scope: 'read mcp:practices:read'),
      registration_params(token_endpoint_auth_method: 'client_secret_basic')
    ]

    invalid_requests.each do |params|
      post '/oauth/register', params:, as: :json

      assert_response :bad_request
      assert_equal 'invalid_client_metadata', response.parsed_body.fetch('error')
    end
  end

  test 'oversized registration bodies on a trailing-slash path are rejected before the controller' do
    post '/oauth/register/', params: registration_params(client_name: 'x' * 9_000), as: :json

    assert_response :content_too_large
  end

  test 'registration is not routable with a format suffix' do
    post '/oauth/register.json', params: registration_params, as: :json

    assert_response :not_found
  end

  test 'DCR enforces the body limit and rejects non-string redirect URIs' do
    post '/oauth/register', params: registration_params(client_name: 'x' * 9_000), as: :json
    assert_response :content_too_large

    post '/oauth/register', params: registration_params(redirect_uris: [nil]), as: :json
    assert_response :bad_request
  end

  test 'DCR limits registration bursts per client IP' do
    10.times do
      post '/oauth/register', params: registration_params, as: :json
      assert_response :created
    end

    post '/oauth/register', params: registration_params, as: :json
    assert_response :too_many_requests
  end

  test 'metadata advertises DCR, S256, and only the supported grant and scope' do
    get '/.well-known/oauth-authorization-server'

    assert_response :ok
    metadata = response.parsed_body
    assert_equal ['authorization_code'], metadata.fetch('grant_types_supported')
    assert_equal ['S256'], metadata.fetch('code_challenge_methods_supported')
    assert_equal ['/oauth/register'], [URI(metadata.fetch('registration_endpoint')).path]
    assert_equal [PRACTICES_SCOPE], metadata.fetch('scopes_supported')
    assert_not metadata.key?('client_id_metadata_document_supported')

    get '/.well-known/oauth-protected-resource/mcp'

    assert_response :ok
    assert_equal RESOURCE, response.parsed_body.fetch('resource')
  end

  test 'non-MCP OAuth clients cannot request the MCP scope' do
    application = Doorkeeper::Application.create!(
      name: 'Legacy API client',
      redirect_uri: CALLBACK,
      scopes: PRACTICES_SCOPE,
      confidential: false
    )
    sign_in(users(:mentormentaro))

    get '/oauth/authorize', params: {
      client_id: application.uid,
      redirect_uri: CALLBACK,
      response_type: 'code',
      scope: PRACTICES_SCOPE
    }

    assert_response :bad_request
    assert_equal 'invalid_scope', response.parsed_body.fetch('error')
  end

  test 'authorization stores resource and requires an active mentor, exact scope, and PKCE S256' do
    application = register_mcp_client
    sign_in(users(:mentormentaro))

    get '/oauth/authorize', params: authorization_params(application, scope: 'read')
    assert_response :bad_request
    assert_equal 'invalid_scope', response.parsed_body.fetch('error')

    params = authorization_params(application)
    get '/oauth/authorize', params: params.except(:code_challenge_method)
    assert_response :bad_request
    assert_equal 'invalid_request', response.parsed_body.fetch('error')

    get '/oauth/authorize', params: params
    assert_response :ok
    assert_select 'h1.auth-form__title', 'アプリケーションとの接続'
    assert_select '.form-actions .form-actions__item.is-main form[action="/oauth/authorize"][method="post"]'
    assert_select '.form-actions .form-actions__item.is-sub form[action="/oauth/authorize"][method="post"] input[name="_method"][value="delete"]'
    assert_select 'form[action="/oauth/authorize"]', 2
    assert_select 'input[name="resource"][value=?]', RESOURCE, 2
    assert_select 'input[name="code_challenge"][value=?]', CHALLENGE, 2
    assert_select 'input[name="code_challenge_method"][value="S256"]', 2

    post '/oauth/authorize', params: params
    assert_response :redirect
    callback = URI(response.headers.fetch('Location'))
    code = URI.decode_www_form(callback.query).to_h.fetch('code')
    grant = Doorkeeper::AccessGrant.find_by!(token: code)

    assert_equal RESOURCE, grant.resource
    assert_equal CHALLENGE, grant.code_challenge
    assert_equal 'S256', grant.code_challenge_method

    users(:mentormentaro).update!(hibernated_at: Time.current)
    post '/oauth/token', params: token_params(application, code)
    assert_response :forbidden
    assert_not grant.reload.revoked?
  end

  test 'authorization consent screen escapes a malicious client name' do
    malicious_name = '<img src=x onerror=alert(1)>'
    application = register_mcp_client(client_name: malicious_name)
    sign_in(users(:mentormentaro))

    get '/oauth/authorize', params: authorization_params(application)

    assert_response :ok
    assert_includes response.body, ERB::Util.html_escape(malicious_name)
    assert_no_match(/#{Regexp.escape(malicious_name)}/, response.body.gsub(ERB::Util.html_escape(malicious_name), ''))
    assert_select 'img[src="x"]', false
  end

  test 'authorization rejects redirect paths and added query parameters while allowing loopback port changes' do
    application = register_mcp_client
    sign_in(users(:mentormentaro))

    get '/oauth/authorize', params: authorization_params(application, redirect_uri: 'http://127.0.0.1:49321/other')
    assert_response :bad_request

    get '/oauth/authorize', params: authorization_params(application, redirect_uri: "#{CALLBACK}?extra=1")
    assert_response :bad_request

    get '/oauth/authorize', params: authorization_params(application, redirect_uri: 'http://127.0.0.1:49321/callback')
    assert_response :ok
  end

  test 'authorization returns one error when resource and scope are both invalid' do
    application = register_mcp_client
    sign_in(users(:mentormentaro))

    get '/oauth/authorize', params: authorization_params(application, resource: 'http://www.example.com/other', scope: 'read')

    assert_response :bad_request
    assert_equal 'invalid_target', response.parsed_body.fetch('error')
  end

  test 'token exchange requires the grant resource and matching PKCE verifier' do
    application = register_mcp_client
    sign_in(users(:mentormentaro))
    params = authorization_params(application)
    post '/oauth/authorize', params: params
    assert_response :redirect
    code = URI.decode_www_form(URI(response.headers.fetch('Location')).query).to_h.fetch('code')
    grant = Doorkeeper::AccessGrant.find_by!(token: code)

    post '/oauth/token', params: token_params(application, code, resource: 'http://www.example.com/other')
    assert_response :bad_request
    assert_equal 'invalid_target', response.parsed_body.fetch('error')
    assert_not grant.reload.revoked?

    post '/oauth/token', params: token_params(application, code, code_verifier: 'wrong-verifier-that-is-long-enough-to-be-valid')
    assert_response :bad_request
    assert_not grant.reload.revoked?

    post '/oauth/token', params: token_params(application, code, redirect_uri: 'http://127.0.0.1:49322/callback')
    assert_response :bad_request
    assert_equal 'invalid_grant', response.parsed_body.fetch('error')
    assert_not grant.reload.revoked?

    post '/oauth/token', params: token_params(application, code)
    assert_response :ok
    token = Doorkeeper::AccessToken.find_by!(token: response.parsed_body.fetch('access_token'))

    assert_equal RESOURCE, token.resource
    assert_equal users(:mentormentaro).id, token.resource_owner_id
    assert_equal PRACTICES_SCOPE, token.scopes.to_s
  end

  test 'authorization rejects a user without mentor or admin role' do
    application = register_mcp_client
    sign_in(users(:kimura))

    get '/oauth/authorize', params: authorization_params(application)

    assert_response :forbidden
    assert_equal 'access_denied', response.parsed_body.fetch('error')

    post '/oauth/authorize', params: authorization_params(application)
    assert_response :forbidden
  end

  test 'browser login returns to the MCP authorization request' do
    application = register_mcp_client

    get '/oauth/authorize', params: authorization_params(application)
    assert_response :redirect
    assert_equal '/login', URI(response.headers.fetch('Location')).path

    post '/user_sessions', params: { user: { login: 'mentormentaro', password: 'testtest' } }
    assert_response :redirect
    location = URI(response.headers.fetch('Location'))
    assert_equal '/oauth/authorize', location.path

    get location.request_uri
    assert_response :ok
  end

  private

  def registration_params(**overrides)
    {
      client_name: 'CLI test client',
      redirect_uris: [CALLBACK],
      grant_types: ['authorization_code'],
      response_types: ['code'],
      token_endpoint_auth_method: 'none'
    }.merge(overrides)
  end

  def register_mcp_client(**overrides)
    post '/oauth/register', params: registration_params(**overrides), as: :json
    assert_response :created
    Doorkeeper::Application.find_by!(uid: response.parsed_body.fetch('client_id'))
  end

  def authorization_params(application, **overrides)
    {
      client_id: application.uid,
      redirect_uri: CALLBACK,
      response_type: 'code',
      scope: PRACTICES_SCOPE,
      state: 'test-state',
      resource: RESOURCE,
      code_challenge: CHALLENGE,
      code_challenge_method: 'S256'
    }.merge(overrides)
  end

  def token_params(application, code, **overrides)
    {
      grant_type: 'authorization_code',
      client_id: application.uid,
      code:,
      redirect_uri: CALLBACK,
      resource: RESOURCE,
      code_verifier: VERIFIER
    }.merge(overrides)
  end
end
