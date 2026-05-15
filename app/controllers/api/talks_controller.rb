# frozen_string_literal: true

class API::TalksController < API::BaseController
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
