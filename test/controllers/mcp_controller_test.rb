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
    assert_equal(%w[get_practice list_practices], tools.map { |tool| tool.fetch('name') }.sort)
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
    messages = []
    logger = Rails.logger

    Rails.cache.stub(:increment, Rails.configuration.x.mcp.requests_per_minute + 1) do
      logger.stub(:info, ->(*arguments) { messages << arguments.first if arguments.any? }) do
        post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)
      end
    end
    assert_response :too_many_requests
    assert_equal 'no-store', response.headers.fetch('Cache-Control')
    assert response.headers.key?('Retry-After')
    assert_includes messages.join, '"result":"rate_limited"'

    Rails.cache.stub(:increment, nil) do
      post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)
    end
    assert_response :service_unavailable
  end

  test 'MCP enforces a global request limit with a distinguishable audit result' do
    token = create_mcp_token
    messages = []
    logger = Rails.logger
    global_key_exceeded = lambda do |key, *_args, **_kwargs|
      key.to_s.include?(':global:') ? Rails.configuration.x.mcp.global_requests_per_minute + 1 : 1
    end

    Rails.cache.stub(:increment, global_key_exceeded) do
      logger.stub(:info, ->(*arguments) { messages << arguments.first if arguments.any? }) do
        post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)
      end
    end

    assert_response :too_many_requests
    assert_equal 'no-store', response.headers.fetch('Cache-Control')
    assert response.headers.key?('Retry-After')
    assert_includes messages.join, '"result":"global_rate_limited"'
  end

  test 'MCP enforces the global request limit on unauthenticated requests within the IP cap' do
    messages = []
    logger = Rails.logger
    global_key_exceeded = lambda do |key, *_args, **_kwargs|
      key.to_s.include?(':global:') ? Rails.configuration.x.mcp.global_requests_per_minute + 1 : 1
    end

    Rails.cache.stub(:increment, global_key_exceeded) do
      logger.stub(:info, ->(*arguments) { messages << arguments.first if arguments.any? }) do
        post '/mcp', params: initialize_request, as: :json
      end
    end

    assert_response :too_many_requests
    assert_equal 'no-store', response.headers.fetch('Cache-Control')
    assert response.headers.key?('Retry-After')
    assert_includes messages.join, '"result":"global_rate_limited"'
  end

  test 'MCP rate limits unauthenticated requests per source IP before the global limit' do
    messages = []
    logger = Rails.logger

    with_unauthenticated_ip_limit(2) do
      post '/mcp', params: initialize_request, as: :json
      assert_response :unauthorized

      post '/mcp', params: initialize_request, as: :json
      assert_response :unauthorized

      logger.stub(:info, ->(*arguments) { messages << arguments.first if arguments.any? }) do
        post '/mcp', params: initialize_request, as: :json
      end
      assert_response :too_many_requests
    end

    assert_equal 'no-store', response.headers.fetch('Cache-Control')
    assert response.headers.key?('Retry-After')
    assert_includes messages.join, '"result":"unauthenticated_ip_rate_limited"'
  end

  test 'MCP unauthenticated IP limits are tracked in separate buckets per remote address' do
    with_unauthenticated_ip_limit(1) do
      post '/mcp', params: initialize_request, as: :json, headers: { 'REMOTE_ADDR' => '203.0.113.10' }
      assert_response :unauthorized

      post '/mcp', params: initialize_request, as: :json, headers: { 'REMOTE_ADDR' => '203.0.113.10' }
      assert_response :too_many_requests

      post '/mcp', params: initialize_request, as: :json, headers: { 'REMOTE_ADDR' => '203.0.113.11' }
      assert_response :unauthorized
    end
  end

  test 'MCP unauthenticated requests rejected by the IP limit do not increment the global counter' do
    counted_keys = []
    counts = Hash.new(0)
    counting = lambda do |key, *_args, **_kwargs|
      counted_keys << key.to_s
      counts[key.to_s] += 1
    end

    with_unauthenticated_ip_limit(1) do
      Rails.cache.stub(:increment, counting) do
        post '/mcp', params: initialize_request, as: :json
        assert_response :unauthorized

        post '/mcp', params: initialize_request, as: :json
        assert_response :too_many_requests
      end
    end

    assert_equal(2, counted_keys.count { |key| key.include?(':unauthenticated-ip:') })
    assert_equal(1, counted_keys.count { |key| key.include?(':global:') })
  end

  test 'MCP requests with a valid bearer token do not consume the unauthenticated IP quota' do
    token = create_mcp_token
    counted_keys = []
    counting = lambda do |key, *_args, **_kwargs|
      counted_keys << key.to_s
      1
    end

    with_unauthenticated_ip_limit(1) do
      Rails.cache.stub(:increment, counting) do
        2.times do
          post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)
          assert_response :ok
        end
      end
    end

    assert_equal(0, counted_keys.count { |key| key.include?(':unauthenticated-ip:') })
  end

  test 'MCP unauthenticated IP rate limit fails closed when the counter is unavailable' do
    Rails.cache.stub(:increment, nil) do
      post '/mcp', params: initialize_request, as: :json
    end
    assert_response :service_unavailable

    Rails.cache.stub(:increment, ->(*) { raise StandardError, 'cache down' }) do
      post '/mcp', params: initialize_request, as: :json
    end
    assert_response :service_unavailable
  end

  test 'MCP rejects spoofed client IP headers as a client error without touching counters' do
    counted_keys = []
    counting = lambda do |key, *_args, **_kwargs|
      counted_keys << key.to_s
      1
    end
    # A Client-Ip header that does not appear in X-Forwarded-For causes
    # ActionDispatch::RemoteIp to raise IpSpoofAttackError.
    spoofed_headers = {
      'REMOTE_ADDR' => '127.0.0.1',
      'X-Forwarded-For' => '203.0.113.10, 198.51.100.20',
      'Client-Ip' => '203.0.113.99'
    }

    Rails.cache.stub(:increment, counting) do
      post '/mcp', params: initialize_request, as: :json, headers: spoofed_headers
    end

    assert_response :bad_request
    assert_empty counted_keys
  end

  test 'MCP rejects spoofed client IP headers as a client error when the controller first resolves remote_ip' do
    counted_keys = []
    counting = lambda do |key, *_args, **_kwargs|
      counted_keys << key.to_s
      1
    end
    spoofed_headers = {
      'REMOTE_ADDR' => '127.0.0.1',
      'X-Forwarded-For' => '203.0.113.10, 198.51.100.20',
      'Client-Ip' => '203.0.113.99'
    }

    # Above info level the request logger never renders the
    # "Started ... for <ip>" line, so nothing resolves request.remote_ip
    # before the unauthenticated IP limiter reads it; the spoof error
    # must surface inside the controller, not in middleware.
    with_log_level(Logger::WARN) do
      Rails.cache.stub(:increment, counting) do
        post '/mcp', params: initialize_request, as: :json, headers: spoofed_headers
      end
    end

    assert_response :bad_request
    assert_empty counted_keys
  end

  test 'MCP counts unauthenticated and authenticated requests exactly once against the global limit' do
    token = create_mcp_token
    counted_keys = []
    counting = lambda do |key, *_args, **_kwargs|
      counted_keys << key.to_s
      1
    end

    Rails.cache.stub(:increment, counting) do
      post '/mcp', params: initialize_request, as: :json
    end
    assert_response :unauthorized
    assert_equal(1, counted_keys.count { |key| key.include?(':global:') })

    counted_keys.clear
    Rails.cache.stub(:increment, counting) do
      post '/mcp', params: initialize_request, as: :json, headers: mcp_headers(token)
    end
    assert_response :ok
    assert_equal(1, counted_keys.count { |key| key.include?(':global:') })
    assert_equal(1, counted_keys.count { |key| key.include?(":#{users(:mentormentaro).id}:") })
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

  def with_log_level(level)
    previous = Rails.logger.level
    Rails.logger.level = level
    yield
  ensure
    Rails.logger.level = previous
  end

  def with_unauthenticated_ip_limit(limit)
    previous = Rails.configuration.x.mcp.unauthenticated_ip_requests_per_minute
    Rails.configuration.x.mcp.unauthenticated_ip_requests_per_minute = limit
    yield
  ensure
    Rails.configuration.x.mcp.unauthenticated_ip_requests_per_minute = previous
  end

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
