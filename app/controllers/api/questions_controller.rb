# frozen_string_literal: true

class API::QuestionsController < API::BaseController
  include Rails.application.routes.url_helpers
  before_action :set_available_emojis, only: %i[show]

  def show
    @question = Question.find(params[:id])
  end

  def update
    question = Question.find(params[:id])

    if !question.nil? && question.update(question_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def question_params
    params.require(:question).permit(:title, :description, :practice_id, :tag_list)
  end
end
