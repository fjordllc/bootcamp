# frozen_string_literal: true

class API::CorrectAnswersController < API::BaseController
  include Rails.application.routes.url_helpers
  before_action :set_question, only: %i[create update]

  def create
    @answer = @question.answers.find(params[:answer_id])
    @answer.type = "CorrectAnswer"
    @answer.save!
    notify_to_slack(@question)
    render json: @answer
  end

  def update
    answer = @question.answers.find(params[:answer_id])
    answer.update!(type: "")
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end

  def notify_to_slack(question)
    name = "#{question.user.login_name}"
    link = "<#{question_url(question)}|#{question.title}>"

    SlackNotification.notify "#{name}が解答を選択しました。#{link}",
                             username: "#{question.user.login_name} (#{question.user.name})",
                             icon_url: question.user.avatar_url,
                             attachments: [{
                               fallback: "question body.",
                               text: question.description
                             }]
  end
end
