# frozen_string_literal: true

class McpController < ActionController::API
  include McpAuditLogging
  include McpOauth::Urls

  PROTOCOL_VERSION = '2025-11-25'
  REQUIRED_SCOPE = McpOauth::RegistrationsController::PRACTICES_SCOPE

  def process_request
    response.headers['Cache-Control'] = 'no-store'
    return forbidden unless canonical_request_host? && canonical_request_origin?

    access_token = bearer_access_token
    return unauthorized unless access_token&.accessible?
    return unless valid_mcp_access_token?(access_token)

    user = active_mcp_user(access_token)
    return unless user

    process_authorized_request(user, access_token.application_id)
  rescue StandardError => e
    Rails.logger.error(audit_log(
                         event: 'mcp.request',
                         result: 'internal_error',
                         exception_class: e.class.name,
                         location: safe_backtrace_location(e)
                       ))
    head :internal_server_error
  end

  private

  def process_authorized_request(user, application_id)
    context = { user:, application_id: }

    case request_limit_status(user.id, application_id)
    when :limited then return rate_limited(context)
    when :global_limited then return rate_limited(context, result: 'global_rate_limited')
    when :unavailable then return rate_limit_unavailable(context)
    end

    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    status, headers, body = transport_for(user).call(request.env)
    headers.each { |name, value| response.headers[name] = value }
    body = body.each.to_a.join
    audit_request(context:, status:, body:, started_at:)
    render body:, status:
  end

  def valid_mcp_access_token?(access_token)
    valid = access_token.scopes.to_a.include?(REQUIRED_SCOPE) &&
            access_token.application&.mcp_client? && access_token.resource == mcp_resource_uri
    return true if valid

    forbidden
    false
  end

  def active_mcp_user(access_token)
    user = User.find_by(id: access_token.resource_owner_id)
    return user if user&.mcp_available?

    forbidden
    nil
  end

  def bearer_access_token
    token = Doorkeeper::OAuth::Token.from_bearer_authorization(request)
    return if token.blank?

    Doorkeeper.config.access_token_model.by_token(token)
  end

  def unauthorized
    response.headers['WWW-Authenticate'] = %(Bearer resource_metadata="#{canonical_origin}/.well-known/oauth-protected-resource/mcp", scope="#{REQUIRED_SCOPE}")
    head :unauthorized
  end

  def forbidden
    head :forbidden
  end

  def canonical_request_host?
    origin = URI(canonical_origin)
    canonical_host = origin.host
    canonical_host.present? && request.host.casecmp?(canonical_host) && request.port == origin.port
  end

  def canonical_request_origin?
    value = request.headers['Origin']
    return true if value.nil?

    origin = URI(value)
    canonical = URI(canonical_origin)
    origin.scheme == canonical.scheme && origin.host.to_s.casecmp?(canonical.host.to_s) && origin.port == canonical.port
  rescue URI::InvalidURIError
    false
  end

  def request_limit_status(user_id, application_id)
    window = Time.current.to_i / 60
    global_count = Mcp::RateLimitCounter.increment("mcp-request:global:#{window}")
    return :unavailable unless global_count

    count = Mcp::RateLimitCounter.increment("mcp-request:#{user_id}:#{window}")
    return :unavailable unless count

    return :global_limited if global_count > Rails.configuration.x.mcp.global_requests_per_minute

    count > Rails.configuration.x.mcp.requests_per_minute ? :limited : :allowed
  rescue StandardError => e
    Rails.logger.error(audit_log(
                         event: 'mcp.rate_limit',
                         user_id:,
                         application_id:,
                         result: 'unavailable',
                         exception_class: e.class.name,
                         location: safe_backtrace_location(e)
                       ))
    :unavailable
  end

  def rate_limit_unavailable(context)
    Rails.logger.error(audit_log(
                         event: 'mcp.rate_limit',
                         user_id: context.fetch(:user).id,
                         application_id: context.fetch(:application_id),
                         result: 'unavailable'
                       ))
    head :service_unavailable
  end

  def rate_limited(context, result: 'rate_limited')
    audit_request(
      context:,
      status: 429,
      body: '',
      started_at: Process.clock_gettime(Process::CLOCK_MONOTONIC),
      result:
    )
    response.headers['Retry-After'] = (60 - Time.current.to_i % 60).to_s
    head :too_many_requests
  rescue StandardError
    head :service_unavailable
  end

  def transport_for(user)
    server = MCP::Server.new(
      name: 'Bootcamp',
      version: '1.0.0',
      tools: [Mcp::ListPractices, Mcp::GetPractice],
      server_context: { user:, canonical_origin: },
      configuration: MCP::Configuration.new(
        protocol_version: PROTOCOL_VERSION,
        exception_reporter: method(:report_sdk_exception)
      )
    )

    MCP::Server::Transports::StreamableHTTPTransport.new(
      server,
      stateless: true,
      enable_json_response: true,
      allowed_hosts: [URI(canonical_origin).host],
      allowed_origins: [canonical_origin],
      serve_subscriptions_listen: false,
      max_request_bytes: Rails.configuration.x.mcp.request_max_bytes
    )
  end
end
