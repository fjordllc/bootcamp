# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :require_login
  before_action :set_page, only: %i(show edit update destroy)
  before_action :set_categories, only: %i(new create edit update)

  def index
    @pages = Page.with_avatar
                 .includes(:comments, :practice)
                 .order(updated_at: :desc)
                 .page(params[:page])
    @pages = @pages.tagged_with(params[:tag]) if params[:tag]
  end

  def show
  end

  def new
    @page = Page.new
  end

  def edit
  end

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
    redirect_to "/pages", notice: "ページを削除しました。"
  end

  private
    def set_page
      @page = Page.find(params[:id])
    end

    def page_params
      if admin_login?
        params.require(:page).permit(:title, :body, :tag_list, :user_id, :practice_id)
      else
        params.require(:page).permit(:title, :body, :tag_list, :practice_id)
      end
    end

    def set_wip
      @page.wip = params[:commit] == "WIP"
    end

    def notice_message(page, action_name)
      return "ページをWIPとして保存しました。" if page.wip?
      case action_name
      when :create
        "ページを作成しました。"
      when :update
        "ページを更新しました。"
      end
    end

    def set_categories
      @categories =
        Category
          .eager_load(:practices)
          .where.not(practices: { id: nil })
          .order("categories.position ASC, practices.position ASC")
    end
end
