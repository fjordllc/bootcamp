# frozen_string_literal: true

require 'application_system_test_case'

class PressKitTest < ApplicationSystemTestCase
  test 'show listing press kit' do
    visit press_kit_url
    assert_equal 'プレスキット | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show recent 6 press releases' do
    8.times do |i|
      article = Article.create(
        title: "press releases #{i}",
        body: 'プレスリリースのタグを持つブログ記事',
        user: users(:komagata),
        wip: false,
        published_at: "2022-1-1 #{i}:00:00"
      )
      article.tag_list.add('プレスリリース')
      article.save
    end

    visit press_kit_path
    assert_selector '.thumbnail-card.a-card', count: 6
  end

  test 'WIP press release is not display' do
    wip_press_release = Article.create(
      title: '非公開のプレスリリース',
      body: '一度公開した後にWIPに戻した最新のプレスリリース',
      user: users(:komagata),
      wip: true,
      published_at: Date.current
    )
    wip_press_release.tag_list.add('プレスリリース')
    wip_press_release.save

    visit press_kit_path
    assert_no_text wip_press_release.title
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

    visit press_kit_path
    top_three_titles = all('h3.thumbnail-card__title').take(3).map(&:text)
    assert_equal [one_day_ago_press_release.title, two_days_ago_press_release.title, three_days_ago_press_release.title], top_three_titles
  end
end
