# frozen_string_literal: true

class ArticlesController < ApplicationController
  before_action :set_article, only: %i[show edit update destroy]
  before_action :require_admin_login, except: %i[index show]

  def index
    @articles = Article.all.order(created_at: :desc).page(params[:page])
    @articles = @articles.tagged_with(params[:tag]) if params[:tag]
    render layout: 'welcome'
  end

  def show
    render layout: "welcome"
  end

  def new
    @article = Article.new
  end

  def edit; end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article, notice: '記事を作成しました'
    else
      render :new
    end
  end

  def update
    if @article.update(article_params)
      redirect_to @article, notice: '記事を更新しました'
    else
      render :edit
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_url, notice: '記事を削除しました'
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :body, :tag_list)
  end
end
