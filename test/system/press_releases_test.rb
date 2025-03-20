# frozen_string_literal: true

require 'application_system_test_case'

class PressReleasesTest < ApplicationSystemTestCase
  test 'show listing press releases' do
    visit press_releases_path
    assert_equal 'プレスリリース | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show only published press releases' do
    press_release = Article.create(
      title: 'プレスリリースのタグを持つ公開済みのブログ記事',
      body: 'test',
      user: users(:komagata),
      wip: false,
      published_at: '2022-1-1 00:00:00'
    )
    press_release.tag_list.add('プレスリリース')
    press_release.save

    wip_press_release = Article.create(
      title: 'プレスリリースのタグを持つwipブログ記事',
      body: 'test',
      user: users(:komagata),
      wip: true
    )
    wip_press_release.tag_list.add('プレスリリース')
    wip_press_release.save

    visit press_releases_path
    assert_text 'プレスリリースのタグを持つ公開済みのブログ記事'
    assert_no_text 'プレスリリースのタグを持つwipブログ記事'
  end

  test 'press releases are displayed from the most recent publication date' do
    three_days_ago_press_release = Article.create(
      title: '3日前に公開されたプレスリリース',
      body: 'test',
      user: users(:komagata),
      wip: false,
      created_at: Date.current - 4.days,
      updated_at: Date.current - 4.days,
      published_at: Date.current - 3.days
    )
    three_days_ago_press_release.tag_list.add('プレスリリース')
    three_days_ago_press_release.save

    two_days_ago_press_release = Article.create(
      title: '2日前に公開されたプレスリリース',
      body: 'test',
      user: users(:komagata),
      wip: false,
      created_at: Date.current - 5.days,
      updated_at: Date.current - 5.days,
      published_at: Date.current - 2.days
    )
    two_days_ago_press_release.tag_list.add('プレスリリース')
    two_days_ago_press_release.save

    one_day_ago_press_release = Article.create(
      title: '1日前に公開されたプレスリリース',
      body: 'test',
      user: users(:komagata),
      wip: false,
      created_at: Date.current - 6.days,
      updated_at: Date.current - 6.days,
      published_at: Date.current - 1.day
    )
    one_day_ago_press_release.tag_list.add('プレスリリース')
    one_day_ago_press_release.save

    visit press_releases_path
    top_three_titles = all('h2.thumbnail-card__title').take(3).map(&:text)
    assert_equal [one_day_ago_press_release.title, two_days_ago_press_release.title, three_days_ago_press_release.title], top_three_titles
  end

  test 'displays up to 24 articles' do
    30.times do |i|
      press_release = Article.create(
        title: "press releases #{i}",
        body: 'プレスリリースのタグを持つブログ記事',
        user: users(:komagata),
        wip: false,
        published_at: "2022-1-1 00:00:#{i}"
      )
      press_release.tag_list.add('プレスリリース')
      press_release.save
    end

    visit press_releases_path
    assert_equal all('.thumbnail-card.a-card').count, 24
  end

  test 'show pagination' do
    number_of_pages = Article.page(1).limit_value + 1
    number_of_pages.times do
      press_release = Article.create(
        title: 'test title',
        body: 'test body',
        user: users(:komagata),
        wip: false,
        published_at: Date.current
      )
      press_release.tag_list.add('プレスリリース')
      press_release.save
    end

    visit press_releases_path
    assert_selector 'nav.pagination', count: 2
  end
end
