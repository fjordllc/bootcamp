# frozen_string_literal: true

class API::QuestionsController < API::BaseController
  include Rails.application.routes.url_helpers
  before_action :set_available_emojis, only: %i[show]

  def index
    questions =
      case params[:target]
      when 'solved'
        Question.solved
      when 'not_solved'
        Question.not_solved.not_wip
      else
        Question.all
      end
    questions = params[:practice_id].present? ? questions.where(practice_id: params[:practice_id]) : questions
    questions = params[:user_id].present? ? Question.where(user_id: params[:user_id]) : questions
    questions = questions.tagged_with(params[:tag]) if params[:tag]
    @questions = questions
                 .with_avatar
                 .includes(:practice, :answers, :tags, :correct_answer)
                 .order(updated_at: :desc, id: :desc)
                 .page(params[:page])
  end

  def show
    @question = Question.find(params[:id])
  end

  def update
    question = Question.find(params[:id])
    if question.update(question_params)
      Newspaper.publish(:question_create, question) unless question.watched?
      head :ok
    else
      head :bad_request
    end
  end

  private

  def question_params
    params.require(:question).permit(:title, :description, :practice_id, :tag_list, :wip)
  end
end
