# frozen_string_literal: true

require 'application_system_test_case'

class PressKitTest < ApplicationSystemTestCase
  test 'show listing press kit' do
    visit press_kit_url
    assert_equal 'プレスキット | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show recent 6 press releases' do
    8.times do |i|
      press_release = Article.create(
        title: "press releases #{i}",
        body: 'プレスリリースのタグを持つブログ記事',
        user: users(:komagata),
        wip: false,
        published_at: "2022-1-1 #{i}:00:00"
      )
      press_release.tag_list.add('プレスリリース')
      press_release.save
    end

    visit press_kit_path
    assert_selector '.thumbnail-card.a-card', count: 6
  end
end
