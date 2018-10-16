class Practices::QuestionsController < ApplicationController
  before_action :set_practice
  before_action :set_questions

  def index
  end

  private
    def set_practice
      @practice = Practice.find(params[:practice_id])
    end

    def set_questions
      questions = @practice.questions.eager_load(:user, :answers)
      @questions =
        if params[:solved].present?
          questions.joins(:correct_answer)
        else
          question_ids = CorrectAnswer.pluck(:question_id)
          questions.where.not(id: question_ids)
        end.order(updated_at: :desc, id: :desc)
    end
end
