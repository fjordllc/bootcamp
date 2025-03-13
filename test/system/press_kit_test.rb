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
end
