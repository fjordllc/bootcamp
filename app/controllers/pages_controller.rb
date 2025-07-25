# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :set_page, only: %i[show edit update destroy]
  before_action :set_categories, only: %i[new create edit update]
  before_action :redirect_to_slug, only: %i[show edit]
  skip_before_action :require_active_user_login, only: %i[show]

  SIDE_LINK_LIMIT = 20
  PAGER_NUMBER = 20

  def index
    @pages = Page.with_avatar
                 .includes(:comments, :practice, :tags,
                           { last_updated_user: { avatar_attachment: :blob } })
                 .order(updated_at: :desc, id: :desc)
                 .page(params[:page])
                 .per(PAGER_NUMBER)
    @pages = @pages.tagged_with(params[:tag]) if params[:tag]
    @tag = ActsAsTaggableOn::Tag.find_by(name: params[:tag])
  end

  def show
    @pages = @page.practice.pages.limit(SIDE_LINK_LIMIT) if @page.practice
    @comments = @page.comments.order(:created_at)

    if logged_in?
      render :show
    else
      render :unauthorized_show, layout: 'not_logged_in'
    end
  end

  def new
    @page = Page.new
  end

  def edit; end

  def create
    @page = Page.new(page_params)
    @page.last_updated_user = current_user
    @page.user ||= current_user
    set_wip
    is_published = @page.published_at?
    if @page.save
      url = Redirection.determin_url(self, @page)
      if !@page.wip?
        Newspaper.publish(:page_create, { page: @page })
        url = new_announcement_url(page_id: @page.id) if @page.announcement_of_publication?
      end

      become_watcher!(@page, [current_user, @page.user])

      redirect_to url, notice: notice_message(@page, is_published)
    else
      render :new
    end
  end

  def update
    set_wip
    @page.last_updated_user = current_user
    is_published = @page.published_at?
    if @page.update(page_params)
      url = Redirection.determin_url(self, @page)
      if @page.saved_change_to_attribute?(:wip, from: true, to: false) && @page.published_at.nil?
        Newspaper.publish(:page_update, { page: @page })
        url = new_announcement_path(page_id: @page.id) if @page.announcement_of_publication?
      end

      become_watcher!(@page, [current_user, @page.user])

      redirect_to url, notice: notice_message(@page, is_published)
    else
      render :edit
    end
  end

  def destroy
    @page.destroy
    redirect_to '/pages', notice: 'ドキュメントを削除しました。'
  end

  private

  def set_page
    @page = Page.search_by_slug_or_id!(params[:slug_or_id])
  end

  def page_params
    keys = %i[title body tag_list practice_id slug announcement_of_publication]
    keys << :user_id if admin_or_mentor_login?
    params.require(:page).permit(*keys)
  end

  def set_wip
    @page.wip = params[:commit] == 'WIP'
  end

  def notice_message(page, is_published)
    return 'ドキュメントをWIPとして保存しました。' if page.wip?

    is_published ? 'ドキュメントを更新しました。' : 'ドキュメントを作成しました。'
  end

  def set_categories
    @categories =
      Category
      .eager_load(:practices, :categories_practices)
      .where.not(practices: { id: nil })
      .order('categories_practices.position')
  end

  def redirect_to_slug
    return if @page.slug.nil?

    redirect_to request.original_url.sub(params[:slug_or_id], @page.slug) unless params[:slug_or_id].start_with?(/[a-z]/)
  end

  def become_watcher!(page, users)
    users.each { |user| user.become_watcher!(page) }
  end
end
