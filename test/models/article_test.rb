# frozen_string_literal: true

require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  test "thumbnail_url" do
    article = articles(:article_1)
    assert_equal "/images/articles/thumbnails/default.png", article.thumbnail_url
  end
end
