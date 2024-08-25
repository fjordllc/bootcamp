# frozen_string_literal: true

class QuestionsController < ApplicationController
  include Rails.application.routes.url_helpers
  before_action :set_question, only: %i[show destroy]
  before_action :set_editable_question, only: %i[edit update]
  before_action :set_categories, only: %i[new show create]
  before_action :set_watch, only: %i[show]
  before_action :require_admin_or_mentor_login, only: [:destroy]
  skip_before_action :require_active_user_login, only: %i[show]

  MAX_PRACTICE_QUESTIONS_DISPLAYED = 20

  def index
    @tag = ActsAsTaggableOn::Tag.find_by(name: params[:tag])
    @tags = Question.all.all_tags
    @questions = Question
                 .by_target(params[:target])
                 .by_practice_id(params[:practice_id])
                 .by_tag(params[:tag])
                 .with_avatar
                 .includes(:practice, :answers, :tags, :correct_answer)
                 .latest_update_order
                 .page(params[:page])
    @questions_property = Question.generate_questions_property(params[:target])
  end

  def show
    @practice_questions = Question
                          .not_wip
                          .where(practice: @question.practice)
                          .where.not(id: @question.id)
                          .includes(:correct_answer)
                          .latest_update_order
                          .limit(MAX_PRACTICE_QUESTIONS_DISPLAYED)
    @answers = @question.answers.order(created_at: :asc).page(params[:page]).per(20)
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
    @question = Question.new(practice_id: params[:practice_id], user_id: current_user.id)
  end

  def edit; end

  def create
    @question = Question.new(question_params)
    @question.user = current_user if !admin_or_mentor_login?
    set_wip
    if @question.save
      Newspaper.publish(:question_create, { question: @question })
      redirect_to Redirection.determin_url(self, @question), notice: @question.generate_notice_message(:create)
    else
      render :new
    end
  end

  def update
    set_wip
    if @question.update(question_params)
      Newspaper.publish(:question_update, { question: @question }) if @question.saved_change_to_wip?
      redirect_to Redirection.determin_url(self, @question), notice: @question.generate_notice_message(:update)
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

  def set_wip
    @question.wip = params[:commit] == 'WIP'
  end
end
