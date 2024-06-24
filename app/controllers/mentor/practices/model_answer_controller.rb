# frozen_string_literal: true

class Mentor::Practices::ModelAnswerController < ApplicationController
  before_action :require_admin_or_mentor_login
  before_action :set_model_answer, only: %i[edit update]

  def new
    @practice = find_practice
    @model_answer = @practice.build_model_answer
  end

  def edit
    @practice = @model_answer.practice
  end

  def create
    @practice = find_practice
    @model_answer = @practice.build_model_answer(model_answer_params)
    if @model_answer.save
      redirect_to practice_model_answer_url, notice: '模範解答を作成しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @practice = @model_answer.practice
    if @model_answer.update(model_answer_params)
      redirect_to practice_model_answer_url, notice: '模範解答を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_model_answer
    @model_answer = ModelAnswer.find_by(practice_id: params[:practice_id])
  end

  def find_practice
    Practice.find(params[:practice_id])
  end

  def model_answer_params
    params.require(:model_answer).permit(:description)
  end
end
