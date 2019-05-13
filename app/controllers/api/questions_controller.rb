# frozen_string_literal: true

class API::QuestionsController < ApplicationController
  def show
    @question = Question.find(params[:id])
    render "show", formats: "json", handlers: "jbuilder"
  end
end
