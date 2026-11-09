# frozen_string_literal: true

module McpOauth
  module Urls
    private

    def canonical_origin
      configured_origin = Rails.configuration.x.mcp.canonical_origin
      return configured_origin if configured_origin.present?
      return request.base_url unless Rails.env.production?

      raise ArgumentError, 'MCP canonical origin is not configured'
    end

    def mcp_resource_uri
      "#{canonical_origin}/mcp"
    end

    def oauth_url(endpoint)
      "#{canonical_origin}/oauth/#{endpoint}"
    end
  end
end
