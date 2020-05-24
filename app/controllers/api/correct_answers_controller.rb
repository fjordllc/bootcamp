# frozen_string_literal: true

class API::CorrectAnswersController < API::BaseController
  include Rails.application.routes.url_helpers
  before_action :require_login
  before_action :set_question, only: %i(create update)

  def create
    # return_to = params[:return_to] ? params[:return_to] : question_url(question)

    # if @answer.save
    #   notify_to_slack(@question)
    #   render :create, status: :created
    # else
    #   head :bad_request
    # end

    # jsonとかで確認する

    @answer = @question.answers.find(params[:answer_id])
    @answer.type = "CorrectAnswer"
    @answer.save!

    # ActiveRecord::Base.transaction do
    #   # binding.pry
    #   @answer = @question.answers.find(params[:answer_id])
    #   @question.correct_answer = @answer.id
    #   @answer.type = "CorrectAnswer"
    #   @answer.save!
    #   @question.save!
    # end
    notify_to_slack(@question)

    # redirect_to return_to, notice: "正解の解答を選択しました。"　　　　vue.jsでやるべき
    pp "0" * 1000
    render(json: @answer).tap(&method(:pp))
  end

  def update
    # return_to = params[:return_to] ? params[:return_to] : question_url(question)
    answer = @question.answers.find(params[:answer_id])
    answer.update!(type: "")
    # redirect_to return_to, notice: "ベストアンサーを取り消しました。"　　　　vue.jsでやるべき
  end

  # ベストアンサーを取り消すのはdeleteかも
  # def delete

  # end

  # { id: answer_id }

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
