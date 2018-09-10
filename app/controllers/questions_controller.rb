class QuestionsController < ApplicationController
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper
  before_action :require_login
  before_action :set_question, only: %i(show edit update destroy)
  before_action :set_categories, only: %i(new edit)

  def index
    @questions =
      if params[:solved].present?
        Question.joins(:correct_answer)
      else
        question_ids = CorrectAnswer.pluck(:question_id)
        Question.where.not(id: question_ids)
      end
  end

  def show
  end

  def new
    @question = Question.new
  end

  def edit
  end

  def create
    @question = Question.new(question_params)
    @question.user = current_user
    if @question.save
      notify_to_slack(@question)
      redirect_to @question, notice: "質問を作成しました。"
    else
      render :new
    end
  end

  def update
    if @question.update(question_params)
      redirect_to @question, notice: "質問を更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @question.destroy
    redirect_to questions_url, notice: "質問を削除しました。"
  end

  private
    def set_question
      @question = Question.find(params[:id])
    end

    def set_categories
      @categories = Category.eager_load(:practices).where.not(practices: { id: nil }).order("categories.position ASC, practices.position ASC")
    end

    def question_params
      params.require(:question).permit(
        :title,
        :description,
        :user_id,
        :resolve,
        :practice_id
      )
    end

    def notify_to_slack(question)
      name = "#{question.user.login_name}"
      link = "<#{question_url(question)}|#{question.title}>"

      notify "#{name}質問しました。#{link}",
        username: "#{question.user.login_name} (#{question.user.full_name})",
        icon_url: gravatar_url(question.user, secure: true),
        attachments: [{
          fallback: "question body.",
          text: question.description
        }]
    end
end
