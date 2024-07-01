# frozen_string_literal: true

class Mentor::Practices::ModelSubmissionController < ApplicationController
  before_action :require_admin_or_mentor_login
  before_action :set_model_submission, only: %i[edit update]

  def new
    @practice = find_practice
    @model_submission = @practice.build_model_submission
  end

  def edit
    @practice = @model_submission.practice
  end

  def create
    @practice = find_practice
    @model_submission = @practice.build_model_submission(model_submission_params)
    if @model_submission.save
      redirect_to practice_model_submission_url, notice: '模範解答を作成しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @practice = @model_submission.practice
    if @model_submission.update(model_submission_params)
      redirect_to practice_model_submission_url, notice: '模範解答を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_model_submission
    @model_submission = ModelSubmission.find_by(practice_id: params[:practice_id])
  end

  def find_practice
    Practice.find(params[:practice_id])
  end

  def model_submission_params
    params.require(:model_submission).permit(:description)
  end
end
