# frozen_string_literal: true

require 'application_system_test_case'

class ArticlesTest < ApplicationSystemTestCase
  setup do
    @article = articles(:article1)
    @article2 = articles(:article2)
  end

  test 'show listing articles' do
    visit_with_auth articles_url, 'komagata'
    assert_text 'ブログ'
    assert_selector '.articles'
  end

  test 'show pagination' do
    Article.delete_all
    user = users(:komagata)
    number_of_pages = Article.page(1).limit_value + 1
    number_of_pages.times do
      Article.create(title: 'test title', body: 'test body', user_id: user.id, wip: false, published_at: Time.current)
    end

    visit_with_auth articles_url, 'komagata'
    assert_selector 'nav.pagination', count: 2
  end

  test 'display recent 10 articles on article page' do
    Article.delete_all
    11.times do |i|
      Article.create(
        title: "test title #{i}",
        body: 'test body',
        user: users(:komagata),
        wip: false,
        published_at: "2021-12-31 #{i}:00:00"
      )
    end

    visit article_path Article.last.id
    titles = all('.card-list-item-title').map(&:text)

    within '.card-list' do
      assert_equal 'test title 10', titles.first
      assert_equal 'test title 1', titles.last
      assert_no_text 'test title 0'
      assert_equal all('.card-list-item').count, 10
    end
  end

  test 'GET /articles/{article_id}' do
    visit "/articles/#{@article.id}"
    assert_equal 'タイトル１ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'articles are displayed from the most recent publication date' do
    three_days_ago_article = Article.create(
      title: '3日前に公開された記事',
      body: 'test',
      user: users(:komagata),
      wip: false,
      created_at: Date.current - 4.days,
      updated_at: Date.current - 4.days,
      published_at: Date.current - 3.days
    )
    two_days_ago_article = Article.create(
      title: '2日前に公開された記事',
      body: 'test',
      user: users(:komagata),
      wip: false,
      created_at: Date.current - 5.days,
      updated_at: Date.current - 5.days,
      published_at: Date.current - 2.days
    )
    one_day_ago_article = Article.create(
      title: '1日前に公開された記事',
      body: 'test',
      user: users(:komagata),
      wip: false,
      created_at: Date.current - 6.days,
      updated_at: Date.current - 6.days,
      published_at: Date.current - 1.day
    )

    visit articles_url
    top_three_titles = all('h2.thumbnail-card__title').take(3).map(&:text)
    assert_equal [one_day_ago_article.title, two_days_ago_article.title, three_days_ago_article.title], top_three_titles
  end
end
