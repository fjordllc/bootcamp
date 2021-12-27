# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :require_login
  before_action :set_page, only: %i[show edit update destroy]
  before_action :set_categories, only: %i[new create edit update]
  before_action :redirect_to_slug, only: %i[show edit]

  def index
    @pages = Page.with_avatar
                 .includes(:comments, :practice, :tags,
                           { last_updated_user: { avatar_attachment: :blob } })
                 .order(updated_at: :desc)
                 .page(params[:page])
    @pages = @pages.tagged_with(params[:tag]) if params[:tag]
    @tag = ActsAsTaggableOn::Tag.find_by(name: params[:tag])
  end

  def show; end

  def new
    @page = Page.new
  end

  def edit; end

  def create
    @page = Page.new(page_params)
    if @page.user
      @page.last_updated_user = current_user
    else
      @page.user = current_user
    end
    set_wip
    if @page.save
      redirect_to @page, notice: notice_message(@page, :create)
    else
      render :new
    end
  end

  def update
    set_wip
    @page.last_updated_user = current_user
    if @page.update(page_params)
      redirect_to @page, notice: notice_message(@page, :update)
    else
      render :edit
    end
  end

  def destroy
    @page.destroy
    redirect_to '/pages', notice: 'ページを削除しました。'
  end

  private

  def set_page
    @page = Page.search_by_slug_or_id(params[:slug_or_id])
  end

  def page_params
    keys = %i[title body tag_list practice_id slug]
    keys << :user_id if admin_or_mentor_login?
    params.require(:page).permit(*keys)
  end

  def set_wip
    @page.wip = params[:commit] == 'WIP'
  end

  def notice_message(page, action_name)
    return 'ページをWIPとして保存しました。' if page.wip?

    case action_name
    when :create
      'ページを作成しました。'
    when :update
      'ページを更新しました。'
    end
  end

  def set_categories
    @categories =
      Category
      .eager_load(:practices)
      .where.not(practices: { id: nil })
      .order('categories.position ASC, categories_practices.position ASC')
  end

  def redirect_to_slug
    return if @page.slug.nil?

    redirect_to request.original_url.sub(params[:slug_or_id], @page.slug) unless params[:slug_or_id].start_with?(/[a-z]/)
  end
end
