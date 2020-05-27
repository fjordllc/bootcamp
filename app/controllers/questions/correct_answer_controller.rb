# frozen_string_literal: true

class Questions::CorrectAnswerController < ApplicationController
  include Rails.application.routes.url_helpers
  before_action :require_login
  before_action :set_question, only: %i(create update)

  def create
    answer = @question.answers.find(params[:answer_id])
    answer.type = "CorrectAnswer"
    answer.save!
    notify_to_slack(@question)
    redirect_to @question, notice: "正解の解答を選択しました。"
  end

  def update
    answer = @question.answers.find(params[:answer_id])
    answer.update!(type: "")
    redirect_to @question, notice: "ベストアンサーを取り消しました。"
  end

  private
    def set_question
      @question = Question.find(params[:question_id])
    end

    def notify_to_slack(question)
      name = "#{question.user.login_name}"
      link = "<#{question_url(question)}|#{question.title}>"

      SlackNotification.notify "#{name}が解答を選択しました。#{link}",
        username: "#{question.user.login_name} (#{question.user.full_name})",
        icon_url: question.user.avatar_url,
        attachments: [{
          fallback: "question body.",
          text: question.description
        }]
    end
end
