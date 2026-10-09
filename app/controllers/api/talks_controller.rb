# frozen_string_literal: true

class API::TalksController < API::BaseController
  before_action :require_admin_login_for_api, only: %i[update]
  before_action -> { doorkeeper_authorize! :write }, only: %i[update], if: -> { doorkeeper_token.present? }

  ALLOWED_TARGETS = %w[all student_and_trainee mentor graduate adviser trainee retired].freeze

  def index; end

  def update
    talk = Talk.find(params[:id])
    talk.update!(talk_params)
    head :no_content
  end

  private

  def talk_params
    params.require(:talk).permit(:action_completed)
  end
end
