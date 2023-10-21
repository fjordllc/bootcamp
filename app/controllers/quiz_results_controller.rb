# frozen_string_literal: true

class QuizResultsController < ApplicationController
  before_action :set_quiz
  def create
    ActiveRecord::Base.transaction do
      quiz_result = QuizResult.create!(quiz: @quiz, user: current_user)
      responses = response_params[:responses_attributes].values.map do |response|
        quiz_result.responses.build(statement_id: response[:statement_id], answer: response[:answer], quiz_result:)
      end
      quiz_result.set_score

      redirect_to quiz_quiz_result_path(@quiz, quiz_result), notice: 'Your answers have been submitted!' if responses.each(&:save!)
    end
  end

  def index
    @quiz_results = @quiz.quiz_results
  end

  def show
    @quiz_result = QuizResult.find(params[:id])
  end

  private

  def set_quiz
    @quiz = Quiz.find(params[:quiz_id])
  end

  def response_params
    params.require(:quiz_result).permit(responses_attributes: %i[answer statement_id])
  end
end
