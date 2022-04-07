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
    @tag = ActsAsTaggableOn::Tag.find_by(name: params[:tag])
    @tags = questions.all_tags
    questions = params[:practice_id].present? ? questions.where(practice_id: params[:practice_id]) : questions
    questions = questions.tagged_with(params[:tag]) if params[:tag]
    @questions = questions
                 .with_avatar
                 .includes(:practice, :answers, :tags, :correct_answer, user: :company)
                 .order(updated_at: :desc, id: :desc)
                 .page(params[:page])
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
    @question.wip = params[:commit] == 'WIP'
    if @question.save
      create_mentors_watch
      redirect_to @question, notice: notice_message(@question)
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
    params.require(:question).permit(:title, :description, :user_id, :resolve, :practice_id, :tag_list)
  end

  def set_watch
    @watch = Watch.new
  end

  def questions_property
    if params[:all] == 'true'
      QuestionsProperty.new('全ての質問', '質問はありません。')
    elsif params[:solved] == 'true'
      QuestionsProperty.new('解決済みの質問一覧', '解決済みの質問はありません。')
    else
      QuestionsProperty.new('未解決の質問一覧', '未解決の質問はありません。')
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

  def notice_message(question)
    return '質問をWIPとして保存しました。' if question.wip?

    '質問を作成しました。'
  end
end
