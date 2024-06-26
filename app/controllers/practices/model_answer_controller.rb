# frozen_string_literal: true

class Practices::ModelAnswerController < ApplicationController
  before_action :check_permission!, only: %i[show]

  def show
    @practice = find_practice
    @model_answer = @practice.model_answer
  end

  private

  def check_permission!
    practice = find_practice
    model_answer = practice.model_answer || ModelAnswer.new(practice:)
    return if policy(model_answer).show?

    redirect_to practice_path(practice), alert: 'プラクティスを修了するまで模範解答は見れません。'
  end

  def find_practice
    Practice.find(params[:practice_id])
  end
end
