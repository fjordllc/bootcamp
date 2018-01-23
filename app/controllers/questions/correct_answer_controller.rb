class Questions::CorrectAnswerController < ApplicationController
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper
  before_action :require_login
  before_action :set_question, only: :create

  def create
    return_to = params[:return_to] ? params[:return_to] : question_url(question)
    answer = @question.answers.find(params[:answer_id])
    answer.type = "CorrectAnswer"
    answer.save!
    notify_to_slack(@question)
    redirect_to return_to, notice: "正解の解答を選択しました。"
  end

  private
    def set_question
      @question = Question.find(params[:question_id])
    end

    def notify_to_slack(question)
      name = "#{question.user.login_name}"
      link = "<#{question_url(question)}|#{question.title}>"

      notify "#{name}が解答を選択しました。#{link}",
        username: "#{question.user.login_name} (#{question.user.full_name})",
        icon_url: gravatar_url(question.user, secure: true),
        attachments: [{
          fallback: "question body.",
          text: question.description
        }]
    end
end
