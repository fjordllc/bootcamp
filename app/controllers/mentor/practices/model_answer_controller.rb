# frozen_string_literal: true

class Mentor::Practices::ModelAnswerController < ApplicationController
  before_action :require_admin_or_mentor_login

  def new
    @practice = Practice.find(params[:practice_id])
    @model_answer = @practice.build_model_answer
  end

  def create
    @practice = Practice.find(params[:practice_id])
    @model_answer = @practice.build_model_answer(model_answer_params)
    if @model_answer.save
      redirect_to practice_model_answer_url(@practice), notice: '模範解答を作成しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def model_answer_params
    params.require(:model_answer).permit(:description)
  end
end
