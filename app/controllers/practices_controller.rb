# frozen_string_literal: true

class PracticesController < ApplicationController
  before_action :require_login
  before_action :require_admin_login, only: %i[new create]
  before_action :require_admin_or_mentor_login, only: %i[edit update]
  before_action :set_course, only: %i[new]
  before_action :set_practice, only: %i[show edit update]

  def show
    @categories = @practice.categories
    @tweet_url = @practice.tweet_url(practice_completion_url(@practice.id))
  end

  def new
    @practice = Practice.new
  end

  def edit; end

  def create
    @practice = Practice.new(practice_params)
    if @practice.save
      ChatNotifier.message("プラクティス：「#{@practice.title}」を作成しました。\r#{url_for(@practice)}")
      redirect_to @practice, notice: 'プラクティスを作成しました。'
    else
      render :new
    end
  end

  def update
    @practice.last_updated_user = current_user
    if @practice.update(practice_params)
      ChatNotifier.message("プラクティス：「#{@practice.title}」を編集しました。\r#{url_for(@practice)}")
      redirect_to @practice, notice: 'プラクティスを更新しました。'
    else
      render :edit
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
      :ogp_image,
      :memo,
      category_ids: [],
      reference_books_attributes: %i[id title price page_url must_read cover description _destroy]
    )
  end

  def set_practice
    @practice = Practice.find(params[:id])
  end

  def set_course
    @course = Course.find(params[:course_id]) if params[:course_id]
  end
end
