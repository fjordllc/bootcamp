# frozen_string_literal: true

require 'json'
require 'stringio'

module Mcp
  class RequestBodyLimit
    REGISTRATION_BODY_LIMIT = 8_192

    def initialize(app)
      @app = app
    end

    def call(env)
      path = normalize_path(env['PATH_INFO'])
      limit = body_limit(path)
      return call_app(env, path) unless limit

      return too_large if env['CONTENT_LENGTH'].to_i > limit

      input = env['rack.input']
      return call_app(env, path) unless input

      call_with_body(env, path, input, limit)
    end

    private

    def call_with_body(env, path, input, limit)
      body = input.read(limit + 1).to_s
      return too_large if body.bytesize > limit

      env['rack.input'] = StringIO.new(body)
      env['mcp.audit_metadata'] = audit_metadata(body) if path == '/mcp' && env['REQUEST_METHOD'] == 'POST'
      call_app(env, path)
    end

    def call_app(env, path)
      @app.call(env)
    rescue ActionDispatch::RemoteIp::IpSpoofAttackError
      raise unless path == '/mcp'

      invalid_remote_ip
    end

    def normalize_path(path)
      ActionDispatch::Journey::Router::Utils.normalize_path(path.to_s)
    end

    def body_limit(path)
      return Rails.configuration.x.mcp.request_max_bytes if path == '/mcp'

      REGISTRATION_BODY_LIMIT if path == '/oauth/register'
    end

    def too_large
      [413, { 'cache-control' => 'no-store', 'content-length' => '0' }, []]
    end

    # Contradictory client-supplied IP headers fail trusted-proxy
    # resolution the first time request.remote_ip is read. That happens
    # in request-lifecycle middleware (e.g. the request log line) before
    # the controller runs, so a controller-level rescue cannot catch it;
    # this middleware is the narrowest MCP-scoped layer that wraps it.
    # The failure occurs before any rate-limit counter is touched, so it
    # is a client error, not cache unavailability: fail with 400 and
    # audit at info level instead of logging a per-request error/stack.
    def invalid_remote_ip
      Rails.logger.info("mcp_audit #{{ event: 'mcp.rate_limit', result: 'invalid_remote_ip' }.to_json}")
      [400, { 'cache-control' => 'no-store', 'content-length' => '0' }, []]
    end

    def audit_metadata(body)
      payload = JSON.parse(body)
      return {} unless payload.is_a?(Hash)

      params = payload['params'].is_a?(Hash) ? payload['params'] : {}
      arguments = params['arguments'].is_a?(Hash) ? params['arguments'] : {}

      {
        method: safe_label(payload['method']),
        tool_name: safe_label(params['name']),
        target_id: safe_target_id(arguments['practice_id'])
      }.compact
    rescue JSON::ParserError
      {}
    end

    def safe_label(value)
      return unless value.is_a?(String) && value.match?(%r{\A[A-Za-z0-9_./-]{1,64}\z})

      value
    end

    def safe_target_id(value)
      return value if value.is_a?(Integer) && value.positive?
      return unless value.is_a?(String) && value.match?(/\A[1-9]\d{0,17}\z/)

      value.to_i
    end
  end
end
