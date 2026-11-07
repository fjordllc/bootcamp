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

    assert_no_difference -> { Doorkeeper::Application.count } do
      post '/oauth/register', params: registration_params, as: :json
      assert_response :too_many_requests
    end
  end

  test 'DCR fails closed with 503 without registering a client when the rate counter is unavailable' do
    assert_no_difference -> { Doorkeeper::Application.count } do
      Rails.cache.stub(:increment, nil) do
        post '/oauth/register', params: registration_params, as: :json
      end
    end
    assert_response :service_unavailable
  end

  test 'DCR treats transient counter errors as unavailable without registering a client' do
    messages = []
    logger = Rails.logger

    logger.stub(:error, ->(*arguments) { messages << arguments.first if arguments.any? }) do
      [
        ActiveRecord::AdapterTimeout,
        ActiveRecord::ConnectionNotEstablished,
        ActiveRecord::ConnectionFailed,
        ActiveRecord::Deadlocked,
        ActiveRecord::LockWaitTimeout,
        ActiveRecord::QueryCanceled,
        ActiveRecord::StatementTimeout
      ].each do |error_class|
        messages.clear
        assert_no_difference -> { Doorkeeper::Application.count }, error_class.name do
          Rails.cache.stub(:increment, ->(*) { raise error_class, 'counter unavailable' }) do
            post '/oauth/register', params: registration_params, as: :json
          end
        end
        assert_response :service_unavailable, error_class.name
        assert_includes messages.grep(/mcp_audit/).join, '"event":"mcp.dcr_rate_limit"', error_class.name
        assert_includes messages.grep(/mcp_audit/).join, '"result":"unavailable"', error_class.name
      end
    end
  end

  test 'DCR propagates unexpected counter errors instead of converting them to 503' do
    application_count = Doorkeeper::Application.count

    [NoMethodError, ActiveRecord::StatementInvalid].each do |error_class|
      assert_raises(error_class, error_class.name) do
        Rails.cache.stub(:increment, ->(*) { raise error_class, 'counter bug' }) do
          post '/oauth/register', params: registration_params, as: :json
        end
      end
    end

    assert_equal application_count, Doorkeeper::Application.count
  end

  test 'DCR rejects spoofed client IP headers before touching counters' do
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
    messages = []
    error_messages = []
    reports = []
    logger = Rails.logger
    original_info = logger.method(:info)
    previous_level = logger.level

    begin
      logger.level = Logger::INFO
      assert_no_difference -> { Doorkeeper::Application.count } do
        logger.stub(:error, ->(*arguments) { error_messages << arguments.first if arguments.any? }) do
          logger.stub(:warn, ->(*arguments) { error_messages << arguments.first if arguments.any? }) do
            Rollbar.stub(:error, ->(*arguments) { reports << arguments }) do
              logger.stub(:info, lambda do |*arguments, &block|
                messages << arguments.first if arguments.any?
                original_info.call(*arguments, &block)
              end) do
                Rails.cache.stub(:increment, counting) do
                  post '/oauth/register', params: registration_params, as: :json, headers: spoofed_headers
                end
              end
            end
          end
        end
      end
    ensure
      logger.level = previous_level
    end

    assert_response :bad_request
    assert_empty counted_keys
    assert_empty error_messages
    assert_empty reports
    audit = messages.grep(/mcp_audit/).join
    assert_includes audit, '"event":"mcp.dcr_rate_limit"'
    assert_includes audit, '"result":"invalid_remote_ip"'
    assert_not_includes audit, '203.0.113.99'
    assert_not_includes audit, '198.51.100.20'
  end

  test 'DCR rejects spoofed client IP headers when the controller first resolves remote_ip' do
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
    messages = []
    error_messages = []
    reports = []
    logger = Rails.logger
    original_info = logger.method(:info)
    previous_level = logger.level
    previous_show_exceptions = Rails.application.env_config['action_dispatch.show_exceptions']

    begin
      logger.level = Logger::WARN
      Rails.application.env_config['action_dispatch.show_exceptions'] = :all
      assert_no_difference -> { Doorkeeper::Application.count } do
        logger.stub(:error, ->(*arguments) { error_messages << arguments.first if arguments.any? }) do
          logger.stub(:warn, ->(*arguments) { error_messages << arguments.first if arguments.any? }) do
            Rollbar.stub(:error, ->(*arguments) { reports << arguments }) do
              logger.stub(:info, lambda do |*arguments, &block|
                messages << arguments.first if arguments.any?
                original_info.call(*arguments, &block)
              end) do
                Rails.cache.stub(:increment, counting) do
                  post '/oauth/register',
                       params: registration_params,
                       as: :json,
                       headers: spoofed_headers
                end
              end
            end
          end
        end
      end
      assert_equal :all, request.env['action_dispatch.show_exceptions']
    ensure
      Rails.application.env_config['action_dispatch.show_exceptions'] = previous_show_exceptions
      logger.level = previous_level
    end

    assert_response :bad_request
    assert_empty counted_keys
    assert_empty error_messages
    assert_empty reports
    audit = messages.grep(/mcp_audit/).join
    assert_includes audit, '"event":"mcp.dcr_rate_limit"'
    assert_includes audit, '"result":"invalid_remote_ip"'
    assert_not_includes audit, '203.0.113.99'
    assert_not_includes audit, '198.51.100.20'
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
    assert_authorization_error_redirect('invalid_scope')

    params = authorization_params(application)
    get '/oauth/authorize', params: params.except(:code_challenge_method)
    assert_authorization_error_redirect('invalid_request')

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

  test 'authorization rejects malformed code_challenge values' do
    application = register_mcp_client
    sign_in(users(:mentormentaro))

    ['!', CHALLENGE[0, 42], "#{CHALLENGE}A", "#{CHALLENGE[0, 42]}="].each do |challenge|
      get '/oauth/authorize', params: authorization_params(application, code_challenge: challenge)

      assert_authorization_error_redirect('invalid_request')
    end
  end

  test 'unauthenticated authorization rejects a request too long for the session cookie' do
    application = register_mcp_client

    get '/oauth/authorize', params: authorization_params(application, state: 'a' * 3000)

    assert_response :bad_request
    assert_equal 'invalid_request', response.parsed_body.fetch('error')
    assert_nil session[:return_to_url]
  end

  test 'unauthenticated authorization stores the request path and redirects to login' do
    application = register_mcp_client

    get '/oauth/authorize', params: authorization_params(application)

    assert_redirected_to '/login'
    assert_match(%r{\A/oauth/authorize\?}, session[:return_to_url])
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
    assert_nil response.location

    get '/oauth/authorize', params: authorization_params(application, redirect_uri: "#{CALLBACK}?extra=1")
    assert_response :bad_request
    assert_nil response.location

    get '/oauth/authorize', params: authorization_params(application, redirect_uri: 'http://127.0.0.1:49321/callback')
    assert_response :ok
  end

  test 'authorization returns one error when resource and scope are both invalid' do
    application = register_mcp_client
    sign_in(users(:mentormentaro))

    get '/oauth/authorize', params: authorization_params(application, resource: 'http://www.example.com/other', scope: 'read')

    assert_authorization_error_redirect('invalid_target')
  end

  test 'authorization returns each MCP failure to a registered callback with state and no grant' do
    application = register_mcp_client
    sign_in(users(:mentormentaro))
    failures = [
      ['invalid_target', { resource: 'http://www.example.com/other' }],
      ['invalid_scope', { scope: 'read' }],
      ['invalid_request', { code_challenge_method: 'plain' }]
    ]

    %i[get post].each do |method|
      failures.each do |error, overrides|
        state = "#{method}-#{error} & 日本語"
        params = authorization_params(application, state:).merge(overrides)

        assert_no_difference -> { Doorkeeper::AccessGrant.count } do
          public_send(method, '/oauth/authorize', params:)
        end

        assert_authorization_error_redirect(error, state:)
      end
    end
  end

  test 'authorization errors use the requested loopback redirect port' do
    application = register_mcp_client
    sign_in(users(:mentormentaro))
    requested = 'http://127.0.0.1:49321/callback'

    params = authorization_params(application, redirect_uri: requested, code_challenge_method: 'plain')
    post '/oauth/authorize', params: params

    assert_authorization_error_redirect('invalid_request', callback: requested)
  end

  test 'authorization does not redirect invalid redirect URIs or unknown clients' do
    application = register_mcp_client
    sign_in(users(:mentormentaro))
    invalid_redirects = [
      [nil, { resource: 'http://www.example.com/other', scope: 'read' }],
      ['not a valid uri', { resource: 'http://www.example.com/other', scope: 'read' }],
      ['http://127.0.0.1:49321/other', { resource: 'http://www.example.com/other', scope: 'read' }],
      ["#{CALLBACK}?extra=1", { resource: 'http://www.example.com/other', scope: 'read' }]
    ]

    %i[get post].each do |method|
      invalid_redirects.each do |redirect_uri, overrides|
        params = authorization_params(application, redirect_uri:, **overrides)
        public_send(method, '/oauth/authorize', params: params)

        assert_response :bad_request
        assert_nil response.location
      end

      public_send(method, '/oauth/authorize', params: authorization_params(
        application,
        client_id: 'unknown-client',
        resource: 'http://www.example.com/other',
        scope: "#{PRACTICES_SCOPE} read"
      ))

      assert_response :bad_request
      assert_nil response.location
    end
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

  test 'authorization allows an active student to complete the consent flow' do
    application = register_mcp_client
    sign_in(users(:kimura))

    params = authorization_params(application)
    get '/oauth/authorize', params: params
    assert_response :ok
    assert_select 'h1.auth-form__title', 'アプリケーションとの接続'

    post '/oauth/authorize', params: params
    assert_response :redirect
    code = URI.decode_www_form(URI(response.headers.fetch('Location')).query).to_h.fetch('code')

    assert_equal users(:kimura).id, Doorkeeper::AccessGrant.find_by!(token: code).resource_owner_id
  end

  test 'authorization rejects an ineligible user' do
    application = register_mcp_client
    sign_in(users(:advijirou))
    state = 'denied & state'

    %i[get post].each do |method|
      assert_no_difference -> { Doorkeeper::AccessGrant.count } do
        public_send(method, '/oauth/authorize', params: authorization_params(application, state:))
      end

      assert_authorization_error_redirect('access_denied', state:)
    end
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

  def assert_authorization_error_redirect(error, state: 'test-state', callback: CALLBACK)
    assert_response :redirect
    assert response.location.start_with?("#{callback}?"), response.location
    query = Rack::Utils.parse_query(URI(response.location).query)
    assert_equal error, query.fetch('error')
    assert_equal state, query.fetch('state')
    assert_not query.key?('code')
    description = query.fetch('error_description')
    assert_predicate description, :present?
    assert_not_includes description, 'Translation missing'
    assert_not_includes description, '{'
    assert_not_includes description, '=>'
    expected_description =
      if error == 'invalid_request'
        I18n.t('doorkeeper.errors.messages.invalid_request.unknown', raise: true)
      else
        I18n.t("doorkeeper.errors.messages.#{error}", raise: true)
      end
    assert_equal expected_description, description
  end

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
