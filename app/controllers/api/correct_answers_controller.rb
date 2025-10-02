# frozen_string_literal: true

class API::CorrectAnswersController < API::BaseController
  before_action :set_question, only: %i[create update]

  def create
    @answer = @question.answers.find(params[:answer_id])
    @answer.type = 'CorrectAnswer'
    if @answer.save
      Newspaper.publish(:answer_save, {
                          answer: @answer,
                          action: "#{self.class.name}##{action_name}"
                        })
      ActiveSupport::Notifications.instrument('correct_answer.save', answer: @answer)
      head :ok
    else
      head :bad_request
    end
  end

  def update
    answer = @question.answers.find(params[:answer_id])
    answer.update!(type: '')
    Newspaper.publish(:answer_save, {
                        answer:,
                        action: "#{self.class.name}##{action_name}"
                      })
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end
end
