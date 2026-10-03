# frozen_string_literal: true

require 'test_helper'

class McpControllerTest < ActionDispatch::IntegrationTest
  RESOURCE = 'http://www.example.com/mcp'

  setup do
    @previous_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rails.cache = @previous_cache
  end

  test 'unauthenticated MCP requests receive an OAuth challenge without protocol processing' do
    post '/mcp', params: initialize_request, as: :json

    assert_response :unauthorized
    assert_match %r{resource_metadata="http://www\.example\.com/\.well-known/oauth-protected-resource/mcp"}, response.headers.fetch('WWW-Authenticate')
    assert_equal 'no-store', response.headers.fetch('Cache-Control')
  end

  test 'valid MCP bearer token can initialize and list the read-only tools' do
    token = create_mcp_token

    post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)

    assert_response :ok
    initialize_response = response.parsed_body
    assert_equal '2025-11-25', initialize_response.dig('result', 'protocolVersion')
    assert_equal 'Bootcamp', initialize_response.dig('result', 'serverInfo', 'name')

    post '/mcp', params: { jsonrpc: '2.0', id: 2, method: 'tools/list' }, as: :json, headers: mcp_headers(token)

    assert_response :ok
    tools = response.parsed_body.dig('result', 'tools')
    assert_equal %w[get_practice list_practices], tools.map { |tool| tool.fetch('name') }.sort
  end

  test 'cookie authentication does not replace the required MCP bearer token' do
    sign_in(users(:mentormentaro))

    post '/mcp', params: initialize_request, as: :json

    assert_response :unauthorized
  end

  test 'MCP rejects inactive users, expired tokens, and tokens without resource binding' do
    token = create_mcp_token
    users(:mentormentaro).update!(retired_on: Date.current)

    post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)
    assert_response :forbidden

    users(:mentormentaro).update!(retired_on: nil)
    token.update!(expires_in: 0, created_at: 2.minutes.ago)
    post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)
    assert_response :unauthorized

    token.update!(expires_in: 3600, created_at: Time.current, resource: nil)
    post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)
    assert_response :forbidden
  end

  test 'MCP rejects ordinary OAuth clients even if they hold the dedicated scope' do
    application = Doorkeeper::Application.create!(
      name: 'Ordinary OAuth client',
      redirect_uri: 'https://client.example/callback',
      scopes: 'mcp:practices:read',
      confidential: false
    )
    token = Doorkeeper::AccessToken.create!(
      application:,
      resource_owner_id: users(:mentormentaro).id,
      token: SecureRandom.hex(32),
      scopes: 'mcp:practices:read',
      resource: RESOURCE,
      expires_in: 3600
    )

    post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)

    assert_response :forbidden
  end

  test 'MCP rate limits authenticated users and fails closed when the shared cache is unavailable' do
    token = create_mcp_token

    Rails.cache.stub(:increment, Rails.configuration.x.mcp.requests_per_minute + 1) do
      post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)
    end
    assert_response :too_many_requests
    assert_equal 'no-store', response.headers.fetch('Cache-Control')
    assert response.headers.key?('Retry-After')

    Rails.cache.stub(:increment, nil) do
      post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)
    end
    assert_response :service_unavailable
  end

  test 'token revocation removes MCP access and pending grants without affecting ordinary OAuth clients' do
    token = create_mcp_token
    grant = Doorkeeper::AccessGrant.create!(
      application: token.application,
      resource_owner_id: token.resource_owner_id,
      token: SecureRandom.hex(32),
      expires_in: 600,
      redirect_uri: 'http://127.0.0.1:48321/callback',
      scopes: 'mcp:practices:read',
      resource: RESOURCE,
      code_challenge: 'test-challenge',
      code_challenge_method: 'S256'
    )
    other_user = users(:adminonly)
    other_user_token = Doorkeeper::AccessToken.create!(
      application: token.application,
      resource_owner_id: other_user.id,
      token: SecureRandom.hex(32),
      scopes: 'mcp:practices:read',
      resource: RESOURCE,
      expires_in: 3600
    )
    other_user_grant = Doorkeeper::AccessGrant.create!(
      application: token.application,
      resource_owner_id: other_user.id,
      token: SecureRandom.hex(32),
      expires_in: 600,
      redirect_uri: 'http://127.0.0.1:48321/callback',
      scopes: 'mcp:practices:read',
      resource: RESOURCE,
      code_challenge: 'test-challenge',
      code_challenge_method: 'S256'
    )
    ordinary_application = Doorkeeper::Application.create!(
      name: 'Ordinary client',
      redirect_uri: 'https://client.example/callback',
      confidential: false
    )
    ordinary_token = Doorkeeper::AccessToken.create!(
      application: ordinary_application,
      resource_owner_id: token.resource_owner_id,
      token: SecureRandom.hex(32),
      scopes: 'read',
      expires_in: 3600
    )

    assert_equal({ access_tokens: 1, authorization_grants: 1 }, Mcp::TokenRevoker.call(user: users(:mentormentaro)))
    assert_predicate token.reload, :revoked?
    assert_predicate grant.reload, :revoked?
    assert_not_predicate other_user_token.reload, :revoked?
    assert_not_predicate other_user_grant.reload, :revoked?
    assert_not_predicate ordinary_token.reload, :revoked?
  end

  test 'MCP audit logging records request metadata without bearer tokens or practice content' do
    token = create_mcp_token
    practice = practices(:practice1)
    messages = []
    logger = Rails.logger

    logger.stub(:info, ->(*arguments) { messages << arguments.first if arguments.any? }) do
      post '/mcp',
           params: {
             jsonrpc: '2.0',
             id: 3,
             method: 'tools/call',
             params: { name: 'get_practice', arguments: { practice_id: practice.id } }
           },
           as: :json,
           headers: mcp_headers(token)
    end

    assert_response :ok
    audit = messages.grep(/mcp_audit/).join("\n")
    assert_includes audit, 'get_practice'
    assert_includes audit, practice.id.to_s
    assert_not_includes audit, token.token
    assert_not_includes audit, practice.description.to_s
    assert_not_includes audit, practice.memo.to_s
  end

  test 'SDK exceptions are logged by class and location without exception or request contents' do
    token = create_mcp_token
    messages = []
    logger = Rails.logger
    request_body = {
      jsonrpc: '2.0',
      id: 4,
      method: 'tools/call',
      params: { name: 'get_practice', arguments: { practice_id: 12_345 } }
    }

    logger.stub(:error, ->(*arguments) { messages << arguments.first if arguments.any? }) do
      Practice.stub(:find_by, ->(*) { raise StandardError, 'exception-secret-marker' }) do
        post '/mcp', params: request_body, as: :json, headers: mcp_headers(token)
      end
    end

    assert_response :ok
    assert_includes messages.join, 'mcp.sdk_error'
    assert_includes messages.join, 'StandardError'
    assert_not_includes messages.join, 'exception-secret-marker'
    assert_not_includes messages.join, 'get_practice'
    assert_not_includes response.body, 'exception-secret-marker'
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

  def mcp_headers(token)
    {
      'Authorization' => "Bearer #{token.token}",
      'Accept' => 'application/json, text/event-stream'
    }
  end

  def create_mcp_token
    application = Doorkeeper::Application.create!(
      name: 'MCP test client',
      redirect_uri: 'http://127.0.0.1:48321/callback',
      scopes: 'mcp:practices:read',
      confidential: false,
      mcp_client: true
    )
    Doorkeeper::AccessToken.create!(
      application:,
      resource_owner_id: users(:mentormentaro).id,
      token: SecureRandom.hex(32),
      scopes: 'mcp:practices:read',
      resource: RESOURCE,
      expires_in: 3600
    )
  end
end
