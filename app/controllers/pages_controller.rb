class PagesController < ApplicationController
  before_action :require_login
  before_action :set_page, only: %i(show edit update destroy)

  def index
    @pages = Page.page(params[:page])
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
      @page = Page.find_by(id: params[:id])
      redirect_to new_page_path unless @page
    end

    def page_params
      params.require(:page).permit(:title, :body)
    end
end
