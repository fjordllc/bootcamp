# frozen_string_literal: true

class API::AnswersController < API::BaseController
  include Rails.application.routes.url_helpers
  before_action :set_answer, only: %i[update destroy]
  before_action :set_available_emojis, only: %i[index create]
  before_action -> { doorkeeper_authorize! :write }, only: %i[create update destroy], if: -> { doorkeeper_token.present? }

  def index
    if params[:question_id].present?
      @answers = question.answers.order(created_at: :asc)
    else
      user = User.find(params[:user_id])
      @answers = user.answers.where(user_id: params[:user_id]).includes(
        {
          question: [
            :correct_answer,
            { user: { avatar_attachment: :blob } },
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
      ActiveSupport::Notifications.instrument('answer.create', answer: @answer)
      render_created_answer(question)
    else
      render_validation_errors(@answer)
    end
  end

  def update
    if @answer.update(answer_params)
      request.format.json? ? render(json: answer_json(@answer), status: :ok) : head(:ok)
    else
      render_validation_errors(@answer)
    end
  end

  def destroy
    @answer.destroy
    ActiveSupport::Notifications.instrument('answer.destroy', answer: @answer, action: current_action_name) if @answer.type == 'CorrectAnswer'
    request.format.json? ? render(json: { id: @answer.id }, status: :ok) : head(:no_content)
  end

  private

  def set_answer
    @answer = current_user.admin? ? Answer.find_by(id: params[:id]) : current_user.answers.find_by(id: params[:id])
    render_not_found('回答が見つかりません。') unless @answer
  end

  def question
    Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:description)
  end

  def render_created_answer(question)
    if request.format.json?
      render json: answer_json(@answer), status: :created
    else
      render partial: 'questions/answer', locals: { question:, answer: @answer, user: current_user }, status: :created
    end
  end

  def answer_json(answer)
    {
      id: answer.id,
      description: answer.description,
      question_id: answer.question_id,
      user: {
        id: answer.user.id,
        login_name: answer.user.login_name,
        name: answer.user.name
      },
      created_at: answer.created_at,
      updated_at: answer.updated_at
    }
  end
end
