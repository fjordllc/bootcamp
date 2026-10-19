# frozen_string_literal: true

class Practices::PracticeQuizController < ApplicationController
  before_action :set_practice
  before_action :set_practice_quiz

  def show
    @questions = @practice_quiz.published_questions.includes(:practice_quiz_choices)
    @passed_attempt = @practice_quiz.passed_attempt_for(current_user)
    @next_attempt_at = @practice_quiz.next_attempt_at_for(current_user)
    @incorrect_questions = incorrect_questions unless @passed_attempt
  end

  private

  def incorrect_questions
    latest_attempt = @practice_quiz.latest_attempt_for(current_user)
    return [] unless latest_attempt

    selected_ids = latest_attempt.practice_quiz_answers.pluck(:practice_quiz_choice_id)
    @questions.each_with_index.filter_map do |question, index|
      choice_ids = selected_ids & question.practice_quiz_choices.map(&:id)
      [question, index + 1] unless question.correct_answer?(choice_ids)
    end
  end

  def set_practice
    @practice = Practice.find(params[:practice_id])
  end

  def set_practice_quiz
    @practice_quiz = @practice.quiz_gate.published_practice_quiz
    redirect_to @practice, alert: '公開中の理解度テストはありません。' if @practice_quiz.blank?
  end
end
