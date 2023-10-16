class ResponsesController < ApplicationController
  before_action :set_quiz

  def create
    @responses = response_params[:responses_attributes].values.map do |response|
      current_user.responses.build(statement_id: response[:statement_id], answer: response[:answer])
    end

    if @responses.all?(&:valid?) && @responses.each(&:save)
      redirect_to quizzes_path, notice: 'Your answers have been submitted!'
    else
      flash.now[:alert] = 'There was an error submitting your answers. Please try again.'
      render 'quizzes/show'
    end
  end

  private

  def set_quiz
    @quiz = Quiz.find(params[:quiz_id])
  end

  def response_params
    params.permit(responses_attributes: [:answer, :statement_id])
  end
end
