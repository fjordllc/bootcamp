# frozen_string_literal: true

require 'application_system_test_case'

class PressKitTest < ApplicationSystemTestCase
  test 'show recent 6 press releases' do
    Article.delete_all

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
end
