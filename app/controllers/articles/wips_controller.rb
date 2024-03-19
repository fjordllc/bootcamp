# frozen_string_literal: true

class Articles::WipsController < ApplicationController
  before_action :require_admin_or_mentor_login, only: %i[index]

  def index
    @articles = wip_articles
    @articles = @articles.tagged_with(params[:tag]) if params[:tag]
    render layout: 'welcome'
  end

  private

  def wip_articles
    articles = Article.with_attached_thumbnail.includes(user: { avatar_attachment: :blob })
    articles.where(wip: true).order(created_at: :desc).page(params[:page])
  end
end
