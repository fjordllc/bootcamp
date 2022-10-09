# frozen_string_literal: true

class API::LatestArticlesController < API::BaseController
  def index
    @latest_articles = LatestArticle.with_attached_thumbnail.page(params[:page])
  end
end
