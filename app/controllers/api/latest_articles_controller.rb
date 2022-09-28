# frozen_string_literal: true

class API::LatestArticlesController < API::BaseController
  def index
    @latest_articles = LatestArticle.page(params[:page])
  end
end
