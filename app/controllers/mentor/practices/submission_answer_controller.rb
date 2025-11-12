# frozen_string_literal: true

class Mentor::Practices::SubmissionAnswerController < ApplicationController
  before_action :require_admin_or_mentor_login
  before_action :set_submission_answer, only: %i[edit update]

  def new
    @practice = Practice.find(params[:practice_id])
    @submission_answer = @practice.build_submission_answer
  end

  def edit
    @practice = @submission_answer.practice
  end

  def create
    @practice = Practice.find(params[:practice_id])
    @submission_answer = @practice.build_submission_answer(submission_answer_params)
    if @submission_answer.save
      redirect_to practice_submission_answer_path, notice: '模範解答を作成しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @practice = @submission_answer.practice
    if @submission_answer.update(submission_answer_params)
      redirect_to practice_submission_answer_path, notice: '模範解答を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_submission_answer
    @submission_answer = SubmissionAnswer.find_by(practice_id: params[:practice_id])
  end

  def submission_answer_params
    params.require(:submission_answer).permit(:description)
  end
end
