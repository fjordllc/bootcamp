# frozen_string_literal: true

class Practices::SubmissionAnswerController < ApplicationController
  before_action :check_permission!, only: %i[show]

  def show
    @practice = Practice.find(params[:practice_id])
    @submission_answer = @practice.submission_answer
  end

  private

  def check_permission!
    practice = Practice.find(params[:practice_id])
    submission_answer = practice.submission_answer || SubmissionAnswer.new(practice:)
    return if policy(submission_answer).show?

    redirect_to practice_path(practice), alert: 'プラクティスを修了するまで模範解答は見れません。'
  end
end
