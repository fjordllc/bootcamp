# frozen_string_literal: true

require 'uri'

module McpConfig
  def self.validate_limits(mcp)
    limits = [
      mcp.request_max_bytes,
      mcp.requests_per_minute,
      mcp.global_requests_per_minute,
      mcp.unauthenticated_ip_requests_per_minute,
      mcp.max_tool_response_bytes
    ]
    return if limits.all?(&:positive?)

    raise ArgumentError, 'MCP size and rate limits must be positive integers'
  end
end

Rails.application.configure do
  config.x.mcp.request_max_bytes = Integer(ENV.fetch('MCP_REQUEST_MAX_BYTES', 1.megabyte.to_s))
  config.x.mcp.requests_per_minute = Integer(ENV.fetch('MCP_REQUESTS_PER_MINUTE', '120'))
  config.x.mcp.global_requests_per_minute = Integer(ENV.fetch('MCP_GLOBAL_REQUESTS_PER_MINUTE', '600'))
  config.x.mcp.unauthenticated_ip_requests_per_minute = Integer(ENV.fetch('MCP_UNAUTHENTICATED_IP_REQUESTS_PER_MINUTE', '60'))
  config.x.mcp.max_tool_response_bytes = Integer(ENV.fetch('MCP_MAX_TOOL_RESPONSE_BYTES', 256.kilobytes.to_s))

  public_origin = ENV['MCP_PUBLIC_ORIGIN'].presence
  if Rails.env.production?
    public_origin ||= "https://#{ENV['APP_HOST_NAME']}" if ENV['APP_HOST_NAME'].present?
    if public_origin.blank? && ENV['SECRET_KEY_BASE'] != 'dummy'
      raise ArgumentError, 'APP_HOST_NAME or MCP_PUBLIC_ORIGIN is required for the MCP canonical origin'
    end
  end

  if public_origin.present?
    uri = URI.parse(public_origin)
    valid_schemes = Rails.env.production? ? [URI::HTTPS] : [URI::HTTP, URI::HTTPS]
    unless valid_schemes.any? { |scheme| uri.is_a?(scheme) } && uri.host.present? && uri.userinfo.nil? && uri.path.blank? && uri.query.nil? && uri.fragment.nil?
      required_scheme = Rails.env.production? ? 'HTTPS' : 'HTTP or HTTPS'
      raise ArgumentError, "MCP_PUBLIC_ORIGIN must be a #{required_scheme} origin without a path, query, or fragment"
    end
    config.x.mcp.canonical_origin = uri.to_s.delete_suffix('/')
  end
end

McpConfig.validate_limits(Rails.application.config.x.mcp)
