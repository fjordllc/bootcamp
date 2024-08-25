# frozen_string_literal: true

class API::CorrectAnswersController < API::BaseController
  include Rails.application.routes.url_helpers
  before_action :set_question, only: %i[create update]

  def create
    @answer = @question.answers.find(params[:answer_id])
    @answer.type = 'CorrectAnswer'
    if @answer.save
      Newspaper.publish(:answer_save, { answer: @answer })
      Newspaper.publish(:correct_answer_save, { answer: @answer })
      ChatNotifier.message("質問：「#{@answer.question.title}」のベストアンサーが選ばれました。\r#{url_for(@answer.question)}")
      head :ok
    else
      head :bad_request
    end
  end

  def update
    answer = @question.answers.find(params[:answer_id])
    answer.update!(type: '')
    Newspaper.publish(:answer_save, { answer: @answer })
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end
end
