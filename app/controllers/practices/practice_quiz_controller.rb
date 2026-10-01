# frozen_string_literal: true

class Practices::PracticeQuizController < ApplicationController
  before_action :set_practice
  before_action :set_practice_quiz

  def show
    @questions = @practice_quiz.published_questions.includes(:practice_quiz_choices)
    @passed_attempt = @practice_quiz.passed_attempt_for(current_user)
    @next_attempt_at = @practice_quiz.next_attempt_at_for(current_user)
  end

  private

  def set_practice
    @practice = Practice.find(params[:practice_id])
  end

  def set_practice_quiz
    @practice_quiz = @practice.published_practice_quiz
    redirect_to @practice, alert: '公開中の理解度テストはありません。' if @practice_quiz.blank?
  end
end
