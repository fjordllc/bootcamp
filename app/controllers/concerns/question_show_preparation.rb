# frozen_string_literal: true

module QuestionShowPreparation
  extend ActiveSupport::Concern

  MAX_PRACTICE_QUESTIONS_DISPLAYED = 20

  private

  def prepare_question_show
    @practice_questions = Question
                          .not_wip
                          .where(practice: @question.practice)
                          .where.not(id: @question.id)
                          .includes(:correct_answer)
                          .latest_update_order
                          .limit(MAX_PRACTICE_QUESTIONS_DISPLAYED)
    @answers = @question.answers.order(created_at: :asc)
  end
end
