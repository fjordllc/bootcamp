# frozen_string_literal: true

module McpOauth
  class TokensController < Doorkeeper::TokensController
    include McpOauth::Urls
    include McpOauth::RedirectUris

    # create is inherited from Doorkeeper::TokensController.
    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :validate_mcp_token_request, only: :create
    # rubocop:enable Rails/LexicallyScopedActionFilter

    private

    def validate_mcp_token_request
      application = server.client&.application || Doorkeeper::Application.find_by(uid: params[:client_id])
      return unless application&.mcp_client?

      validate_mcp_token_record(application)
    end

    def validate_mcp_token_record(application)
      grant = mcp_grant(application)
      return render_oauth_error('invalid_grant') unless grant
      return render_oauth_error('invalid_target') unless valid_resource?(grant)
      return render_oauth_error('invalid_grant') unless params[:redirect_uri] == grant.redirect_uri
      return render_oauth_error('invalid_grant', :forbidden) unless User.find_by(id: grant.resource_owner_id)&.mcp_available?

      true
    end

    def valid_resource?(grant)
      params[:resource] == grant.resource && grant.resource == mcp_resource_uri
    end

    def mcp_grant(application)
      return unless params[:grant_type] == 'authorization_code'

      Doorkeeper.config.access_grant_model.by_token(params[:code])&.then { |record| record if record.application_id == application.id }
    end

    def render_oauth_error(error, status = :bad_request)
      render json: { error: }, status: status
    end
  end
end
