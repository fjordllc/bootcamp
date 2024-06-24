# frozen_string_literal: true

class Practices::ModelAnswerController < ApplicationController
  before_action :set_model_answer, only: %i[show]
  before_action :check_permission!, only: %i[show]

  def show
    @practice = @model_answer.practice
  end

  private

  def set_model_answer
    @model_answer = ModelAnswer.find_by(practice_id: params[:practice_id])
  end

  def check_permission!
    return if policy(@model_answer).show?

    redirect_to practice_path(@model_answer.practice), alert: 'プラクティスを修了するまで模範解答は見れません。'
  end
end
