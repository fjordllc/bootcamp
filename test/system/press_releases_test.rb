# frozen_string_literal: true

require 'application_system_test_case'

class PressReleasesTest < ApplicationSystemTestCase
  test 'show listing press releases' do
    visit press_releases_path
    assert_equal 'プレスリリース | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
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
