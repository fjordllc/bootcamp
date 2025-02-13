# frozen_string_literal: true

class Articles::SponsorshipsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[index]
  MAX_PAGE_COUNT = 12

  layout 'lp'

  def index
    @articles = sponsorships_articles.per(MAX_PAGE_COUNT)
  end

  private

  def sponsorships_articles
    Article.with_attached_thumbnail.includes(user: { avatar_attachment: :blob })
           .where(thumbnail_type: :sponsorship, wip: false).order(created_at: :desc).page(params[:page])
  end
end
