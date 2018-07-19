class PagesController < ApplicationController
  before_action :require_login
  before_action :set_page, only: %i(show edit update destroy)

  def index
    @pages = Page.page(params[:page]).per(20)
  end

  def show
  end

  def new
    title = params[:title] || ""
    @page = Page.new(title: title)
  end

  def edit
  end

  def create
    @page = Page.new(page_params)
    if @page.save
      redirect_to "/pages/#{@page.title}", notice: "ページを作成しました。"
    else
      render :new
    end
  end

  def update
    if @page.update(page_params)
      redirect_to "/pages/#{@page.title}", notice: "ページを更新しました。"
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
      @page = Page.find_by(title: params[:title])
      redirect_to "/pages/new?title=#{params[:title]}" unless @page
    end

    def page_params
      params.require(:page).permit(:title, :body)
    end
end
