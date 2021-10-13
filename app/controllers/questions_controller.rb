# frozen_string_literal: true

class QuestionsController < ApplicationController
  include Rails.application.routes.url_helpers
  before_action :require_login
  before_action :set_question, only: %i[show destroy]
  before_action :set_categories, only: %i[new show create]
  before_action :set_watch, only: %i[show]

  QuestionsProperty = Struct.new(:title, :empty_message)

  def index
    questions =
      if params[:solved].present?
        Question.solved
      elsif params[:all].present?
        Question.all
      else
        Question.not_solved
      end
    @tag = params[:tag]
    @tags = questions.all_tags
    questions = params[:practice_id].present? ? questions.where(practice_id: params[:practice_id]) : questions
    questions = questions.tagged_with(params[:tag]) if params[:tag]
    questions = questions.includes(:practice, :answers).order(updated_at: :desc, id: :desc)
    @questions = questions.with_avatar.page(params[:page])
    @questions_property = questions_property
  end

  def show
    respond_to do |format|
      format.html
      format.md
    end
  end

  def new
    @question = Question.new
  end

  def create
    @question = Question.new(question_params)
    @question.user = current_user
    if @question.save
      create_mentors_watch
      notify_to_chat(@question)
      redirect_to @question, notice: '質問を作成しました。'
    else
      render :new
    end
  end

  def destroy
    @question.destroy
    redirect_to questions_url, notice: '質問を削除しました。'
  end

  private

  def set_question
    @question = Question.find(params[:id])
  end

  def set_categories
    @categories =
      Category
      .eager_load(:practices)
      .where.not(practices: { id: nil })
      .order('categories.position ASC, categories_practices.position ASC')
  end

  def question_params
    params.require(:question).permit(
      :title,
      :description,
      :user_id,
      :resolve,
      :practice_id,
      :tag_list
    )
  end

  def notify_to_chat(question)
    ChatNotifier.message("質問：#{question.title}が作成されました。\r#{question_url(question)}")
  end

  def set_watch
    @watch = Watch.new
  end

  def questions_property
    if params[:all] == 'true'
      QuestionsProperty.new('全ての質問', '質問はまだありません。')
    elsif params[:solved] == 'true'
      QuestionsProperty.new('解決済みの質問一覧', '解決済みの質問はまだありません。')
    else
      QuestionsProperty.new('未解決の質問一覧', '未解決の質問はまだありません。')
    end
  end

  def create_mentors_watch
    Watch.insert_all(watch_records) # rubocop:disable Rails/SkipsModelValidations
  end

  def watch_records
    User.mentor.map do |mentor|
      {
        watchable_type: 'Question',
        watchable_id: @question.id,
        created_at: Time.current,
        updated_at: Time.current,
        user_id: mentor.id
      }
    end
  end
end
