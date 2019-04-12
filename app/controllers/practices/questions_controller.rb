# frozen_string_literal: true

class Practices::QuestionsController < MemberAreaController
  before_action :set_practice
  before_action :set_questions

  def index
  end

  private
    def set_practice
      @practice = Practice.find(params[:practice_id])
    end

    def set_questions
      questions = practice.questions.eager_load(:user, :answers)
      @questions =
        if params[:solved].present?
          questions.solved
        else
          questions.not_solved
        end.order(updated_at: :desc, id: :desc)
    end

    def practice
      @practice ||= Practice.find(params[:practice_id])
    end
end
