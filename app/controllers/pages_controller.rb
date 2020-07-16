# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :require_login
  before_action :set_page, only: %i(show edit update destroy)

  def index
    @pages = Page.with_avatar.order(updated_at: :desc).page(params[:page])
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
    @page.user = current_user
    if @page.save
      redirect_to @page, notice: "ページを作成しました。"
    else
      render :new
    end
  end

  def update
    if @page.update(page_params)
      redirect_to @page, notice: "ページを更新しました。"
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
      params.require(:page).permit(:title, :body, :tag_list)
    end
end
