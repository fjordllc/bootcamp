# frozen_string_literal: true

class Practices::ModelAnswerController < ApplicationController
  def show
    @practice = Practice.find(params[:practice_id])
    @model_answer = @practice.model_answer
  end
end
