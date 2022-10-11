# frozen_string_literal: true

require 'test_helper'

class LatestArticleTest < ActiveSupport::TestCase
  test 'thumbnail_url' do
    latest_article = latest_articles(:latest_article1)
    assert_equal '/images/latest_articles/thumbnails/default.png', latest_article.thumbnail_url
  end
end
