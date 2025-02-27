# frozen_string_literal: true

require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test '.with_attachments_and_user' do
    articles = Article.with_attachments_and_user

    articles.each do |article|
      assert_not_nil article.user
      assert_not_nil article.user.avatar_attachment
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
    assert articles(:article1).published?
    assert_not articles(:article3).published?
  end

  test '#before_initial_publish?' do
    assert_not articles(:article1).before_initial_publish?
    assert articles(:article3).before_initial_publish?
  end

  test '#generate_token!' do
    test_article = Article.create(
      title: 'サンプル記事',
      body: 'サンプル記事本文',
      user: users(:komagata),
      wip: true
    )
    test_article.generate_token!
    assert_not_nil test_article.token

    maintained_tokens = test_article.token
    test_article.generate_token!
    assert_equal maintained_tokens, test_article.token
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

  test 'featured scope returns articles tagged with "注目の記事" in descending order and limited to 6' do
    articles = Article.featured
    assert_equal articles.sort_by(&:published_at).reverse, articles
    assert_equal 6, articles.size

    articles.each do |article|
      assert_not article.wip?
      assert_includes article.tag_list, '注目の記事'
    end
  end
end
