# frozen_string_literal: true

class Practices::PracticeQuiz::AttemptsController < ApplicationController
  before_action :set_practice
  before_action :set_practice_quiz

  def create
    if @practice_quiz.passed_by?(current_user)
      redirect_to practice_practice_quiz_path(@practice), notice: '理解度テストに合格済みです。'
      return
    end

    unless @practice_quiz.attemptable_by?(current_user)
      redirect_to practice_practice_quiz_path(@practice), alert: retry_message
      return
    end

    attempt = save_attempt

    if attempt.passed?
      redirect_to practice_practice_quiz_path(@practice), notice: '理解度テストに合格しました。'
    else
      redirect_to practice_practice_quiz_path(@practice), alert: '理解度テストは不合格でした。復習してから再度受験してください。'
    end
  end

  private

  def save_attempt
    PracticeQuizAttempt.transaction do
      attempt = PracticeQuizAttempt.create_with_answers!(
        practice_quiz: @practice_quiz,
        user: current_user,
        answers: params[:answers] || {}
      )
      complete_learning_if_ready if attempt.passed?
      attempt
    end
  end

  def set_practice
    @practice = Practice.find(params[:practice_id])
  end

  def set_practice_quiz
    @practice_quiz = @practice.published_practice_quiz
    redirect_to @practice, alert: '公開中の理解度テストはありません。' if @practice_quiz.blank?
  end

  def retry_message
    "次回は #{I18n.l(@practice_quiz.next_attempt_at_for(current_user), format: :long)} 以降に受験できます。"
  end

  def complete_learning_if_ready
    return if @practice.submission? || !@practice.completable_by?(current_user)

    learning = Learning.find_or_initialize_by(user: current_user, practice: @practice)
    return if learning.complete?

    learning.update!(status: :complete)
    ActiveSupport::Notifications.instrument('learning.create', user: learning.user)
  end
end
