# frozen_string_literal: true

class API::AnswersController < API::BaseController
  include Rails.application.routes.url_helpers
  before_action :set_answer, only: %i[update destroy]
  before_action :set_available_emojis, only: %i[index create]

  def index
    if params[:question_id].present?
      @answers = question.answers.order(created_at: :asc)
    else
      user = User.find(params[:user_id])
      @answers = user.answers.where(user_id: params[:user_id]).includes(
        {
          question: [
            :correct_answer,
            { user: [:company, { avatar_attachment: :blob }] },
            :practice,
            :tag_taggings,
            :tags
          ]
        }
      ).order(created_at: :desc).page(params[:page])
    end
  end

  def create
    question = Question.find(params[:question_id])
    @answer = question.answers.new(answer_params)
    @answer.user = current_user
    if @answer.save
      render :create, status: :created
    else
      head :bad_request
    end
  end

  def update
    if @answer.update(answer_params)
      head :ok
    else
      head :bad_request
    end
  end

  def destroy
    @answer.destroy
  end

  private

  def set_answer
    @answer = current_user.admin? ? Answer.find(params[:id]) : current_user.answers.find(params[:id])
  end

  def question
    Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:description)
  end
end
