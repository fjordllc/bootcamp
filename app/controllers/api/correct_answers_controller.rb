# frozen_string_literal: true

class API::CorrectAnswersController < API::BaseController
  before_action -> { doorkeeper_authorize! :write }, only: %i[create update], if: -> { doorkeeper_token.present? }
  before_action :set_question, only: %i[create update]
  before_action :authorize_question, only: %i[create update]

  def create
    success = @question.with_lock do
      @answer = @question.answers.find(params[:answer_id])
      correct_answer = @question.correct_answer
      next true if correct_answer&.id == @answer.id
      next false if correct_answer
      next false unless @answer.update(type: 'CorrectAnswer')

      ActiveSupport::Notifications.instrument('answer.save', answer: @answer, action: current_action_name)
      ActiveSupport::Notifications.instrument('correct_answer.save', answer: @answer)
      true
    end
    render_result(success)
  end

  def update
    success = @question.with_lock do
      @answer = @question.answers.find(params[:answer_id])
      next true unless @answer.type == 'CorrectAnswer'
      next false unless @answer.update(type: nil)

      ActiveSupport::Notifications.instrument('answer.save', answer: @answer, action: current_action_name)
      true
    end
    render_result(success)
  end

  private

  def render_result(success)
    @question.reload
    respond_to do |format|
      format.turbo_stream { success ? render(:update) : head(:unprocessable_entity) }
      format.json do
        status = action_name == 'create' ? :ok : :no_content
        head(success ? status : :bad_request)
      end
      format.html do
        message = action_name == 'create' ? 'ベストアンサーを選択できませんでした。' : 'ベストアンサーを取り消せませんでした。'
        redirect_to question_path(@question, anchor: "answer_#{@answer.id}"), status: :see_other, alert: success ? nil : message
      end
    end
  end

  def set_question
    @question = Question.find(params[:question_id])
  end

  def authorize_question
    return if current_user.admin? || current_user.mentor? || @question.user == current_user

    head :forbidden
  end
end
