# frozen_string_literal: true

class QuestionsController < ApplicationController
  include Rails.application.routes.url_helpers
  before_action :set_question, only: %i[show destroy]
  before_action :set_editable_question, only: %i[edit update]
  before_action :set_categories, only: %i[new show create]
  before_action :set_watch, only: %i[show]
  before_action :require_admin_or_mentor_login, only: [:destroy]
  skip_before_action :require_active_user_login, only: %i[show]

  QuestionsProperty = Struct.new(:title, :empty_message)

  MAX_PRACTICE_QUESTIONS_DISPLAYED = 20

  def index
    questions =
      case params[:target]
      when 'solved'
        Question.solved
      when 'not_solved'
        Question.not_solved.not_wip
      else
        Question.all
      end
    @tag = ActsAsTaggableOn::Tag.find_by(name: params[:tag])
    @tags = Question.all.all_tags
    questions = params[:practice_id].present? ? questions.where(practice_id: params[:practice_id]) : questions
    questions = questions.tagged_with(params[:tag]) if params[:tag]
    @questions = questions
                 .with_avatar
                 .includes(:practice, :answers, :tags, :correct_answer)
                 .order(updated_at: :desc, id: :desc)
                 .page(params[:page])
    @questions_property = questions_property
  end

  def show
    @practice_questions = Question
                          .not_wip
                          .where(practice: @question.practice)
                          .where.not(id: @question.id)
                          .includes(:correct_answer)
                          .order(updated_at: :desc, id: :desc)
                          .limit(MAX_PRACTICE_QUESTIONS_DISPLAYED)
    respond_to do |format|
      format.html
      format.md
    end

    if logged_in?
      render :show
    else
      render :unauthorized_show, layout: 'not_logged_in'
    end
  end

  def new
    @question = Question.new
  end

  def edit; end

  def create
    @question = current_user.questions.new(question_params)
    @question.wip = params[:commit] == 'WIP'
    if @question.save
      Newspaper.publish(:question_create, { question: @question })
      redirect_to Redirection.determin_url(self, @question), notice: notice_message(@question, :create)
    else
      render :new
    end
  end

  def update
    @question.wip = params[:commit] == 'WIP'
    if @question.update(question_params)
      Newspaper.publish(:question_update, { question: @question }) if @question.saved_change_to_wip?
      redirect_to Redirection.determin_url(self, @question), notice: notice_message(@question, :update)
    else
      render :edit
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

  def set_editable_question
    @question = current_user.mentor? ? Question.find(params[:id]) : current_user.questions.find(params[:id])
  end

  def set_categories
    @categories =
      Category
      .eager_load(:practices)
      .where.not(practices: { id: nil })
      .order('categories_practices.position')
  end

  def question_params
    params.require(:question).permit(:title, :description, :user_id, :resolve, :practice_id, :tag_list)
  end

  def set_watch
    @watch = Watch.new
  end

  def questions_property
    case params[:target]
    when 'solved'
      QuestionsProperty.new('解決済みのQ&A', '解決済みのQ&Aはありません。')
    when 'not_solved'
      QuestionsProperty.new('未解決のQ&A', '未解決のQ&Aはありません。')
    else
      QuestionsProperty.new('全てのQ&A', 'Q&Aはありません。')
    end
  end

  def notice_message(question, action_name)
    return '質問をWIPとして保存しました。' if question.wip?

    case action_name
    when :create
      '質問を作成しました。'
    when :update
      '質問を更新しました。'
    end
  end
end
