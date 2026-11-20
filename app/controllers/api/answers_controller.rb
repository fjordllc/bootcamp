# frozen_string_literal: true

class API::AnswersController < API::BaseController
  include QuestionShowPreparation
  include Rails.application.routes.url_helpers
  before_action :set_answer, only: %i[update destroy]
  before_action :set_available_emojis, only: %i[index create update]
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
    @question = Question.find(params[:question_id])
    @answer = @question.answers.new(answer_params)
    @answer.user = current_user
    if @answer.save
      ActiveSupport::Notifications.instrument('answer.create', answer: @answer)
      render_created_answer
    else
      render_invalid_answer
    end
  end

  def update
    @question = @answer.question
    if @answer.update(answer_params)
      render_updated_answer
    else
      @editing_answer = @answer
      render_invalid_update
    end
  end

  def destroy
    destroyed = @answer.destroy
    ActiveSupport::Notifications.instrument('answer.destroy', answer: @answer, action: current_action_name) if destroyed && @answer.type == 'CorrectAnswer'
    render_destroy
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

  def render_created_answer
    respond_to do |format|
      format.turbo_stream { render :create, status: :created }
      format.json { render json: answer_json(@answer), status: :created }
      format.html do
        redirect_to question_path(@question, anchor: "answer_#{@answer.id}"),
                    status: :see_other, notice: '回答を投稿しました！'
      end
    end
  end

  def render_invalid_answer
    respond_to do |format|
      format.turbo_stream { render :create, status: :unprocessable_entity }
      format.json { render_validation_errors(@answer) }
      format.html do
        prepare_question_show
        render 'questions/show', status: :unprocessable_entity
      end
    end
  end

  def render_updated_answer
    respond_to do |format|
      format.turbo_stream
      format.json { render json: answer_json(@answer), status: :ok }
      format.html { redirect_to question_path(@question, anchor: "answer_#{@answer.id}"), status: :see_other }
    end
  end

  def render_invalid_update
    respond_to do |format|
      format.turbo_stream { render :update, status: :unprocessable_entity }
      format.json { render_validation_errors(@answer) }
      format.html do
        prepare_question_show
        @answer = Answer.new
        render 'questions/show', status: :unprocessable_entity
      end
    end
  end

  def render_destroy
    @question = @answer.question.reload
    respond_to do |format|
      format.turbo_stream { @answer.destroyed? ? render(:destroy) : head(:unprocessable_entity) }
      format.json { @answer.destroyed? ? render(json: { id: @answer.id }, status: :ok) : render_validation_errors(@answer) }
      format.html do
        anchor = @answer.destroyed? ? helpers.dom_id(@question, :answers) : "answer_#{@answer.id}"
        redirect_to question_path(@question, anchor: anchor), status: :see_other,
                                                              alert: @answer.destroyed? ? nil : '回答を削除できませんでした。'
      end
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
