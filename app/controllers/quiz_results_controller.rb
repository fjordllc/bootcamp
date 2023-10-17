class QuizResultsController < ApplicationController
  before_action :set_quiz
  def create
    ActiveRecord::Base.transaction do
      quiz_result = QuizResult.create!(quiz: @quiz, user: current_user)
      responses = response_params[:responses_attributes].values.map do |response|
        quiz_result.responses.build(statement_id: response[:statement_id], answer: response[:answer])
      end
      quiz_result.set_score

      redirect_to quizzes_path, notice: 'Your answers have been submitted!' if responses.each(&:save!)
    end
  end

  private
  def set_quiz
    @quiz = Quiz.find(params[:quiz_id])
  end

  def response_params
    params.require(:quiz_result).permit(responses_attributes: %i[answer statement_id])
  end
end
