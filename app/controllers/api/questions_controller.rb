# frozen_string_literal: true

class API::QuestionsController < API::BaseController
  before_action :set_question, only: %i(update)

  def update
    if @question.update(question_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def set_question
    @question =
      if current_user.admin? || current_user.mentor?
        Question.find(params[:id])
      else
        current_user.questions.find(params[:id])
      end
  end

  def question_params
    params.require(:question).permit(:tag_list)
  end
end
