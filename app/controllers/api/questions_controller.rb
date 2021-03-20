# frozen_string_literal: true

class API::QuestionsController < API::BaseController
  include Rails.application.routes.url_helpers
  before_action :set_editable_question, only: %i[update destroy]
  before_action :set_available_emojis, only: %i[show]

  def show
    @question = Question.find(params[:id])
  end

  def update
    if @question.update(question_params)
      head :ok
    else
      head :bad_request
    end
  end

  def destroy
    @question.destroy!
  end

  private

  def set_editable_question
    @question =
      if current_user.admin? || current_user.mentor?
        Question.find(params[:id])
      else
        current_user.questions.find(params[:id])
      end
  end

  def question_params
    params.require(:question).permit(:title, :description, :practice_id, :tag_list)
  end
end
