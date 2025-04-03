# frozen_string_literal: true

class Articles::SponsorshipsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[index]
  PAGER_NUMBER = 12

  layout 'lp'

  def index
    @articles = sponsorships_articles.per(PAGER_NUMBER)
  end

  private

  def sponsorships_articles
    Article.with_attached_thumbnail.includes(user: { avatar_attachment: :blob })
           .tagged_with('スポンサーシップ').where(wip: false).order(published_at: :desc).page(params[:page])
  end
end
