# frozen_string_literal: true

class AnswersController < ApplicationController
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper
  before_action :require_login
  before_action :set_question
  before_action :set_answer, only: %i(show edit update destroy)
  before_action :set_return_to, only: %i(create update destroy)

  def edit
  end

  def create
    @answer = @question.answers.new(answer_params)
    @answer.user = current_user

    if @answer.save
      notify_to_slack(@answer)
      redirect_to @return_to, notice: "解答を作成しました。"
    else
      render :new
    end
  end

  def update
    if @answer.update(answer_params)
      redirect_to @return_to, notice: "解答を編集しました。"
    else
      render :edit
    end
  end

  def destroy
    @answer.destroy
    redirect_to @return_to, notice: "解答を削除しました。"
  end

  private
    def set_question
      @question = Question.find(params[:question_id])
    end

    def set_answer
      @answer = question.answers.find(params[:id])
    end

    def question
      @question ||= Question.find(params[:question_id])
    end

    def answer_params
      params.require(:answer).permit(:description)
    end

    def set_return_to
      @return_to = params[:return_to].present? ? params[:return_to] : question_url(question)
    end

    def notify_to_slack(answer)
      name = "#{answer.user.login_name}"
      link = "<#{question_url(answer.question)}|#{answer.question.title}>"

      notify "#{name}が回答しました。#{link}",
        username: "#{answer.user.login_name} (#{answer.user.full_name})",
        icon_url: gravatar_url(answer.user, secure: true),
        attachments: [{
          fallback: "answer body.",
          text: answer.description
        }]
    end
end
