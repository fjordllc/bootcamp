# frozen_string_literal: true

class API::Articles::SummariesController < API::BaseController
  before_action -> { doorkeeper_authorize! :write }, if: -> { doorkeeper_token.present? }
  before_action :require_admin_or_mentor_login_for_api

  def create
    return render json: { error: '本文が空です' }, status: :unprocessable_entity if params[:body].blank?

    result = Article.agent_summary(params[:body])
    status = result[:error] ? :internal_server_error : :ok
    render json: result, status:
  end
end
