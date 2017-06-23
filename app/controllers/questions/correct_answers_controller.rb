class Questions::CorrectAnswersController < ApplicationController
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper
  before_action :require_login

  def create
    question = Question.find(params[:question_id])
    answer = question.answers.find_by(id: params[:answer_id])
    return_to = params[:return_to] ? params[:return_to] : question_url(question)
    question.correct_answer = answer
    question.save!
    notify_to_slack(question)
    redirect_to return_to, notice: "正解の解答を選択しました。"
  end

  private
    def notify_to_slack(question)
      name = "#{question.user.login_name}"
      link = "<#{question_url(question)}|#{question.title}>"

      notify "#{name}が解答を選択しました。#{link}",
        username: "#{question.user.login_name} (#{question.user.full_name})",
        icon_url: gravatar_url(question.user),
        attachments: [{
          fallback: "question body.",
          text: question.description
        }]
    end
end
