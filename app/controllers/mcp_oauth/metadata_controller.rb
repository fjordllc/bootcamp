# frozen_string_literal: true

module McpOauth
  class MetadataController < ActionController::API
    include McpOauth::Urls

    PRACTICES_SCOPE = McpOauth::RegistrationsController::PRACTICES_SCOPE

    def authorization_server
      render json: {
        issuer: canonical_origin,
        authorization_endpoint: oauth_url(:authorize),
        token_endpoint: oauth_url(:token),
        revocation_endpoint: oauth_url(:revoke),
        registration_endpoint: oauth_url(:register),
        response_types_supported: ['code'],
        grant_types_supported: ['authorization_code'],
        token_endpoint_auth_methods_supported: ['none'],
        code_challenge_methods_supported: ['S256'],
        scopes_supported: [PRACTICES_SCOPE],
        authorization_response_iss_parameter_supported: false
      }, status: :ok
    end

    def protected_resource
      render json: {
        resource: mcp_resource_uri,
        authorization_servers: [canonical_origin],
        scopes_supported: [PRACTICES_SCOPE],
        bearer_methods_supported: ['header']
      }, status: :ok
    end
  end
end
