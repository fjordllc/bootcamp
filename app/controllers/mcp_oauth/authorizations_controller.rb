# frozen_string_literal: true

module McpOauth
  class AuthorizationsController < Doorkeeper::AuthorizationsController
    include McpOauth::Urls
    include McpOauth::RedirectUris

    # S256 の code_challenge は SHA-256 (32 バイト) を padding なしの base64url にした 43 文字。
    CODE_CHALLENGE_FORMAT = /\A[A-Za-z0-9_-]{43}\z/
    # return_to_url はセッション Cookie (4KB 上限) に入るため、暗号化・base64 による増加と他のセッション内容を見込んだ上限。
    MAX_RETURN_TO_URL_BYTESIZE = 2048

    # These actions are inherited from Doorkeeper::AuthorizationsController.
    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :validate_mcp_authorization, only: %i[new create]
    # rubocop:enable Rails/LexicallyScopedActionFilter

    private

    def pre_auth
      @pre_auth ||= pre_authorization_class.new(Doorkeeper.configuration, pre_auth_params, current_resource_owner)
    end

    def pre_authorization_class
      application = Doorkeeper::Application.find_by(uid: params[:client_id])
      application&.mcp_client? ? McpOauth::PreAuthorization : Doorkeeper::OAuth::PreAuthorization
    end

    def validate_mcp_authorization
      application = Doorkeeper::Application.find_by(uid: params[:client_id])
      requested_scopes = params[:scope].to_s.split
      mcp_scope = McpOauth::RegistrationsController::PRACTICES_SCOPE

      return unless validate_client_scope(application, requested_scopes, mcp_scope)
      return unless application&.mcp_client?

      validate_mcp_client_authorization(application, requested_scopes, mcp_scope)
    end

    def validate_mcp_client_authorization(application, requested_scopes, mcp_scope)
      return unless validate_mcp_resource_and_redirect(application)
      return render_oauth_error('invalid_scope') unless valid_mcp_scope?(requested_scopes, mcp_scope)

      params[:scope] = mcp_scope if requested_scopes.empty?
      return render_oauth_error('invalid_request') unless valid_authorization_request?
      return render_oauth_error('access_denied', :forbidden) unless current_resource_owner&.mcp_available?

      true
    end

    def validate_mcp_resource_and_redirect(application)
      @mcp_resource_uri = mcp_resource_uri
      unless params[:resource] == @mcp_resource_uri
        render_oauth_error('invalid_target')
        return false
      end
      unless registered_redirect_uri?(application, params[:redirect_uri])
        render_oauth_error('invalid_request')
        return false
      end

      true
    end

    def validate_client_scope(application, requested_scopes, mcp_scope)
      return true if valid_client_scope?(application, requested_scopes, mcp_scope)

      render_oauth_error('invalid_scope')
      false
    end

    def valid_client_scope?(application, requested_scopes, mcp_scope)
      !requested_scopes.include?(mcp_scope) || application&.mcp_client?
    end

    def valid_mcp_scope?(requested_scopes, mcp_scope)
      requested_scopes.empty? || requested_scopes == [mcp_scope]
    end

    def valid_authorization_request?
      params[:response_type] == 'code' &&
        params[:code_challenge_method] == 'S256' &&
        CODE_CHALLENGE_FORMAT.match?(params[:code_challenge].to_s)
    end

    def can_authorize_response?
      return super unless Doorkeeper.config.custom_access_token_attributes.include?(:resource)
      return false if pre_auth.client.application.mcp_client?

      pre_auth.client.application.confidential? && matching_token?
    end

    def render_oauth_error(error, status = :bad_request)
      return render json: { error: }, status: status unless redirectable_mcp_authorization_error?

      redirect_or_render(oauth_error_response(error))
    end

    def oauth_error_response(error)
      attributes = { state: params[:state], redirect_uri: params[:redirect_uri] }
      return Doorkeeper::OAuth::InvalidRequestResponse.new(**attributes) if error == 'invalid_request'

      Doorkeeper::OAuth::ErrorResponse.new(**attributes, name: error.to_sym)
    end

    def redirectable_mcp_authorization_error?
      application = Doorkeeper::Application.find_by(uid: params[:client_id])
      application&.mcp_client? && registered_redirect_uri?(application, params[:redirect_uri])
    end
  end
end
