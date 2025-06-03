# frozen_string_literal: true

require 'application_system_test_case'

class HomeBasicAccessTest < ApplicationSystemTestCase
  test 'GET / without sign in' do
    logout
    visit '/'
    assert_equal 'プログラミングスクール FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /' do
    visit_with_auth '/', 'komagata'
    assert_equal 'ダッシュボード | FBC', title
  end

  test 'show and close welcome message' do
    visit_with_auth '/', 'advijirou'
    assert_text 'ようこそ'
    click_button '閉じる'
    visit '/'
    assert_no_text 'ようこそ'
  end

  test 'not show welcome message' do
    visit_with_auth '/', 'komagata'
    assert_no_text 'ようこそ'
  end

  test 'toggles_mentor_profile_visibility' do
    visit '/'
    assert_text '駒形 真幸'
    assert_text '株式会社ロッカの代表兼エンジニア。Rubyが大好きで怖話、フィヨルドブートキャンプなどを開発している。'
    visit_with_auth edit_current_user_path, 'komagata'
    uncheck 'プロフィール公開', allow_label_click: true
    click_on '更新する'
    assert_text 'ユーザー情報を更新しました。'
    logout
    visit '/'
    assert_no_text '駒形 真幸'
    assert_no_text '株式会社ロッカの代表兼エンジニア。Rubyが大好きで怖話、フィヨルドブートキャンプなどを開発している。'
  end
end
