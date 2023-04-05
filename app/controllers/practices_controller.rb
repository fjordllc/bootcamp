# frozen_string_literal: true

class PracticesController < ApplicationController
  before_action :require_admin_or_mentor_login, only: %i[new create edit update]
  before_action :set_course, only: %i[new]
  before_action :set_practice, only: %i[show edit update]
  skip_before_action :require_active_user_login, only: %i[show]

  def show
    @categories = @practice.categories
    @tweet_url = @practice.tweet_url(practice_completion_url(@practice.id))
    @common_page = Page.find_by(slug: 'practice_common_description')
    @common_page = nil if @common_page&.wip?

    if logged_in?
      render :show
    else
      render :unauthorized_show, layout: 'not_logged_in'
    end
  end

  def new
    @practice = Practice.new
  end

  def edit; end

  def create
    @practice = Practice.new(practice_params)
    if @practice.save
      ChatNotifier.message("プラクティス：「#{@practice.title}」を#{current_user.login_name}さんが作成しました。\r#{url_for(@practice)}")
      redirect_to @practice, notice: 'プラクティスを作成しました。'
    else
      render :new
    end
  end

  def update
    @practice.last_updated_user = current_user
    if @practice.update(practice_params)
      ChatNotifier.message("プラクティス：「#{@practice.title}」を#{current_user.login_name}さんが編集しました。\r#{url_for(@practice)}")
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
