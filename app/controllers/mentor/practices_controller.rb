# frozen_string_literal: true

class Mentor::PracticesController < ApplicationController
  PER_PAGE = 50
  before_action :require_admin_or_mentor_login, only: %i[index new create edit update destroy]
  before_action :set_course, only: %i[new]
  before_action :set_practice, only: %i[edit update destroy]

  def index
    @practices = Practice.for_mentor_index.page(params[:page]).per(PER_PAGE)
  end

  def new
    @practice = Practice.new
  end

  def edit; end

  def create
    @practice = Practice.new(practice_params)
    if @practice.save
      ChatNotifier.message("プラクティス：「#{@practice.title}」を#{current_user.login_name}さんが作成しました。\r<#{url_for(@practice)}>")
      redirect_to @practice, notice: 'プラクティスを作成しました。'
    else
      render :new
    end
  end

  def update
    @practice.last_updated_user = current_user
    if @practice.update(practice_params)
      ChatNotifier.message("プラクティス：「#{@practice.title}」を#{current_user.login_name}さんが編集しました。\r<#{url_for(@practice)}>")
      redirect_to @practice, notice: 'プラクティスを更新しました。'
    else
      render :edit
    end
  end

  def destroy
    title = @practice.title
    if @practice.destroy
      ChatNotifier.message("プラクティス：「#{title}」を#{current_user.login_name}さんが削除しました。")
      redirect_to mentor_practices_path, notice: 'プラクティスを削除しました。'
    else
      redirect_to @practice, alert: 'プラクティスの削除に失敗しました。'
    end
  end

  private

  def practice_params
    params.require(:practice).permit(
      :title,
      :description,
      :goal,
      :submission,
      :open_product,
      :include_progress,
      :completion_image,
      :memo,
      :summary,
      :ogp_image,
      category_ids: [],
      practices_books_attributes: %i[id book_id must_read _destroy]
    )
  end

  def set_practice
    @practice = Practice.find(params[:id])
  end

  def set_course
    @course = Course.find(params[:course_id]) if params[:course_id]
  end
end
