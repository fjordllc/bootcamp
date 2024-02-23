# frozen_string_literal: true

require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test '.fetch_recent_articles' do
    recent_articles = Article.fetch_recent_articles

    assert_equal recent_articles.count, 10
    recent_articles.each do |article|
      assert_not article.wip
    end
  end

  test '#prepared_thumbnail_url' do
    article = articles(:article3)
    assert_equal '/ogp/blank.svg', article.prepared_thumbnail_url
  end

  test '#selected_thumbnail_url' do
    article = articles(:article1)
    assert_equal '/ogp/ruby_on_rails.png', article.selected_thumbnail_url
  end

  test '#published?' do
    public = articles(:article1)
    wip = articles(:article3)

    assert public.published?
    assert_not wip.published?
  end

  test 'articles directly published without WIP have value of the published_at' do
    article = Article.create(
      title: '公開された記事',
      body: 'WIPを経由せずに公開された記事本文',
      user: users(:komagata),
      wip: false
    )
    assert article.published_at?
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
    assert article.published_at?
  end
end
