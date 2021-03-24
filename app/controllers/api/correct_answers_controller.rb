# frozen_string_literal: true

class API::CorrectAnswersController < API::BaseController
  include Rails.application.routes.url_helpers
  before_action :set_question, only: %i[create update]

  def create
    @answer = @question.answers.find(params[:answer_id])
    @answer.type = 'CorrectAnswer'
    @answer.save!
    render json: @answer
  end

  def update
    answer = @question.answers.find(params[:answer_id])
    answer.update!(type: '')
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end
end
