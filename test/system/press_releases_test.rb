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
end
