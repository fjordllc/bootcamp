# frozen_string_literal: true

class API::Articles::SummariesController < API::BaseController
  before_action -> { doorkeeper_authorize! :write }, if: -> { doorkeeper_token.present? }
  before_action :require_admin_or_mentor_login_for_api

  def create
    render json: Article.agent_summary(params[:body])
  end
end
