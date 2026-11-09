# frozen_string_literal: true

require 'test_helper'

class McpTransportTest < ActionDispatch::IntegrationTest
  RESOURCE = 'http://www.example.com/mcp'
  SCOPE = 'mcp:practices:read'
  PROTOCOL_VERSION = '2025-11-25'

  setup do
    @previous_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rails.cache = @previous_cache
  end

  test 'accepted JSON-RPC notifications receive HTTP 202 with an empty body' do
    post '/mcp',
         params: { jsonrpc: '2.0', method: 'notifications/initialized' },
         as: :json,
         headers: mcp_headers

    assert_response :accepted
    assert_empty response.body
  end

  test 'oversized MCP bodies on a trailing-slash path are rejected' do
    post '/mcp/',
         params: 'x' * (Rails.configuration.x.mcp.request_max_bytes + 1),
         headers: mcp_headers.merge('Content-Type' => 'application/json')

    assert_response :content_too_large
  end

  test 'MCP is not routable with a format suffix' do
    post '/mcp.json', params: { jsonrpc: '2.0', method: 'notifications/initialized' }, as: :json, headers: mcp_headers

    assert_response :not_found
  end

  test 'POST requires JSON content and a supported Accept type' do
    post '/mcp',
         params: initialize_request.to_json,
         headers: mcp_headers.merge('Content-Type' => 'text/plain')
    assert_response :unsupported_media_type

    post '/mcp',
         params: initialize_request.to_json,
         headers: mcp_headers.merge('Accept' => 'text/plain')
    assert_response :not_acceptable
  end

  test 'unsupported initialize protocol version negotiates the server supported version' do
    request = initialize_request
    request[:params][:protocolVersion] = '2099-01-01'

    post '/mcp', params: request, as: :json, headers: mcp_headers

    assert_response :ok
    assert_equal PROTOCOL_VERSION, response.parsed_body.dig('result', 'protocolVersion')
  end

  test 'unsupported MCP protocol version header returns HTTP 400' do
    post '/mcp',
         params: { jsonrpc: '2.0', id: 2, method: 'tools/list' },
         as: :json,
         headers: mcp_headers.merge('MCP-Protocol-Version' => '2099-01-01')

    assert_response :bad_request
    assert_equal(-32_022, response.parsed_body.dig('error', 'code'))
  end

  test 'unknown JSON-RPC method returns a method-not-found error in a JSON response' do
    post '/mcp',
         params: { jsonrpc: '2.0', id: 3, method: 'unknown/method' },
         as: :json,
         headers: mcp_headers.merge('MCP-Protocol-Version' => PROTOCOL_VERSION)

    assert_response :ok
    assert_equal 'application/json', response.media_type
    assert_equal(-32_601, response.parsed_body.dig('error', 'code'))
  end

  test 'invalid JSON returns a parse error without exposing parser details' do
    post '/mcp', params: '{', headers: mcp_headers.merge('Content-Type' => 'application/json')

    assert_response :bad_request
    assert_equal(-32_700, response.parsed_body.dig('error', 'code'))
    assert_equal 'Parse error: Invalid JSON', response.parsed_body.dig('error', 'message')
  end

  test 'stateless transport rejects GET and accepts DELETE without retaining session state' do
    get '/mcp', headers: mcp_headers.merge('Accept' => 'text/event-stream')
    assert_response :method_not_allowed

    delete '/mcp', headers: mcp_headers.merge('MCP-Protocol-Version' => PROTOCOL_VERSION)
    assert_response :ok
    assert_equal({ 'success' => true }, response.parsed_body)
  end

  test 'requests from an unapproved Origin receive HTTP 403' do
    with_public_origin do
      post '/mcp',
           params: initialize_request,
           as: :json,
           headers: mcp_headers.merge('Origin' => 'https://evil.example')
    end

    assert_response :forbidden
  end

  test 'requests whose Origin differs from the canonical scheme or port receive HTTP 403' do
    with_public_origin('https://www.example.com') do
      post '/mcp',
           params: initialize_request,
           as: :json,
           headers: mcp_headers('https://www.example.com/mcp').merge('Host' => 'www.example.com:443', 'Origin' => 'https://www.example.com')
      assert_response :ok

      ['http://www.example.com:443', 'https://www.example.com:8443', 'null', 'http://'].each do |origin|
        post '/mcp',
             params: initialize_request,
             as: :json,
             headers: mcp_headers('https://www.example.com/mcp').merge('Host' => 'www.example.com:443', 'Origin' => origin)

        assert_response :forbidden, origin
      end
    end
  end

  test 'requests from the canonical Origin and without Origin are accepted' do
    [{ 'Origin' => 'http://www.example.com' }, {}].each do |extra|
      with_public_origin do
        post '/mcp', params: initialize_request, as: :json, headers: mcp_headers.merge(extra)
      end

      assert_response :ok, extra.inspect
    end
  end

  test 'oversized PUT bodies on MCP receive HTTP 413' do
    put '/mcp',
        params: 'x' * (Rails.configuration.x.mcp.request_max_bytes + 1),
        headers: mcp_headers.merge('Content-Type' => 'application/json')

    assert_response :content_too_large
  end

  test 'requests with an unapproved Host receive HTTP 403' do
    with_public_origin do
      post '/mcp',
           params: initialize_request,
           as: :json,
           headers: mcp_headers.merge('Host' => 'evil.example')
    end

    assert_response :forbidden
  end

  test 'requests with an unapproved Host port receive HTTP 403' do
    with_public_origin do
      post '/mcp',
           params: initialize_request,
           as: :json,
           headers: mcp_headers.merge('Host' => 'www.example.com:8080')
    end

    assert_response :forbidden
  end

  test 'POST bodies above the SDK request-size limit receive HTTP 413' do
    oversized_json = JSON.generate('x' * (Rails.configuration.x.mcp.request_max_bytes + 1))

    post '/mcp', params: oversized_json, headers: mcp_headers.merge('Content-Type' => 'application/json')

    assert_response :content_too_large
  end

  test 'valid requests receive the configured JSON response content type' do
    post '/mcp',
         params: initialize_request,
         as: :json,
         headers: mcp_headers

    assert_response :ok
    assert_equal 'application/json', response.media_type
  end

  private

  def initialize_request
    {
      jsonrpc: '2.0',
      id: 1,
      method: 'initialize',
      params: {
        protocolVersion: PROTOCOL_VERSION,
        capabilities: {},
        clientInfo: { name: 'transport-test-client', version: '1.0' }
      }
    }
  end

  def mcp_headers(resource = RESOURCE)
    {
      'Authorization' => "Bearer #{create_mcp_token(resource)}",
      'Accept' => 'application/json, text/event-stream'
    }
  end

  def create_mcp_token(resource)
    application = Doorkeeper::Application.create!(
      name: 'MCP transport test client',
      redirect_uri: 'http://127.0.0.1:48321/callback',
      scopes: SCOPE,
      confidential: false,
      mcp_client: true
    )
    token = Doorkeeper::AccessToken.create!(
      application:,
      resource_owner_id: users(:mentormentaro).id,
      token: SecureRandom.hex(32),
      scopes: SCOPE,
      resource:,
      expires_in: 3600
    )
    token.token
  end

  def with_public_origin(origin = 'http://www.example.com')
    previous_origin = Rails.configuration.x.mcp.canonical_origin
    Rails.configuration.x.mcp.canonical_origin = origin
    yield
  ensure
    Rails.configuration.x.mcp.canonical_origin = previous_origin
  end
end
