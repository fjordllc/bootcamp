# frozen_string_literal: true

class API::AnswersController < API::BaseController
  include Rails.application.routes.url_helpers
  before_action :require_login
  before_action :set_answer, only: %i(update destroy)
  before_action :set_question, only: %i(create)
  before_action :set_available_emojis, only: %i(index create)

  def index
    @answers = question.answers.order(created_at: :asc)
  end

  def create
    @answer = @question.answers.new(answer_params)
    @answer.user = current_user
    @answer.question = question
    if @answer.save
      notify_to_slack(@answer)
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

    def set_question
      @question = Question.find(params[:question_id])
    end

    def set_answer
      @answer = current_user.admin? ? Answer.find(params[:id]) : current_user.answers.find(params[:id])
    end

    def question
      Question.find(params[:question_id])
    end

    def answer_params
      params.require(:answer).permit(:description)
    end

    def notify_to_slack(answer)
      name = "#{answer.user.login_name}"
      link = "<#{question_url(answer.question)}|#{answer.question.title}>"

      SlackNotification.notify "#{name}が回答しました。#{link}",
        username: "#{answer.user.login_name} (#{answer.user.full_name})",
        icon_url: answer.user.avatar_url,
        attachments: [{
          fallback: "answer body.",
          text: answer.description
        }]
    end
end
