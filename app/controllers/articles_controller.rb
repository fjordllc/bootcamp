# frozen_string_literal: true

class ArticlesController < ApplicationController
  before_action :set_article, only: %i[show edit update destroy]
  before_action :require_admin_login, except: %i[index show]

  def index
    @articles = list_articles
    @articles = @articles.tagged_with(params[:tag]) if params[:tag]
    render layout: 'article'
  end

  def show
    if !@article.wip? || admin_or_mentor_login?
      render layout: "welcome"
    else
      redirect_to root_path, alert: '管理者・メンターとしてログインしてください'
    end
  end

  def new
    @article = Article.new
  end

  def edit; end

  def create
    @article = Article.new(article_params)
    @article.user = current_user
    set_wip_or_published_time
    if @article.save
      redirect_to redirect_url(@article), notice: notice_message(@article)
    else
      render :new
    end
  end

  def update
    set_wip_or_published_time
    if @article.update(article_params)
      redirect_to redirect_url(@article), notice: notice_message(@article)
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

  def list_articles
    if admin_or_mentor_login?
      Article.all.order(created_at: :desc)
    else
      Article.all.where(wip: false).order(created_at: :desc)
    end
  end

  def article_params
    params.require(:article).permit(:title, :body, :tag_list)
  end

  def redirect_url(article)
    article.wip? ? edit_article_url(article) : article
  end

  def set_wip_or_published_time
    if params[:commit] == 'WIP'
      @article.wip = true
    else
      @article.wip = false
      @article.published_at = Time.current
    end
  end

  def notice_message(article)
    case params[:action]
    when 'create'
      article.wip? ? '記事をWIPとして保存しました' : '記事を作成しました'
    when 'update'
      article.wip? ? '記事をWIPとして保存しました' : '記事を更新しました'
    end
  end
end
