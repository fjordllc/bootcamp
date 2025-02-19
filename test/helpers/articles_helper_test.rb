# frozen_string_literal: true

require 'test_helper'

class ArticlesHelperTest < ActionView::TestCase
  test '#feature_tag?' do
    article = articles(:article1).dup
    assert_not feature_tag?(article)
    article.tag_list = ['注目の記事']
    article.save!
    assert feature_tag?(article)
  end
end
