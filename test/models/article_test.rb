# frozen_string_literal: true

require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test 'thumbnail_url' do
    article = articles(:article1)
    assert_equal '/images/articles/thumbnails/default.png', article.thumbnail_url
  end

  test 'articles directly published without WIP have value of the published_at' do
    article = Article.create(
      title: '公開された記事',
      body: 'WIPを経由せずに公開された記事本文',
      user: users(:komagata),
      wip: false
    )
    assert article.published_at
  end

  test 'once articles published, value of the published_at can be kept at WIP.' do
    article = Article.create(
      title: '一度公開された記事をWIPに',
      body: '一度公開され、その後WIPになった記事本文',
      user: users(:komagata),
      wip: false
    )
    published_at_when_not_wip = article.published_at

    article.update(
      wip: true
    )
    assert_equal article.published_at, published_at_when_not_wip
  end

  test 'articles directly kept at WIP do not have value of the published_at' do
    article = Article.create(
      title: '未公開の記事',
      body: '一度も公開したことがないWIP記事',
      user: users(:komagata),
      wip: true
    )
    assert_nil article.published_at
  end

  test 'once articles directly kept at WIP is published, value of the published_at is not nil' do
    article = Article.create(
      title: '未公開の記事',
      body: '一度も公開したことがないWIP記事',
      user: users(:komagata),
      wip: true
    )

    article.update(
      wip: false
    )
    assert article.published_at
  end
end
