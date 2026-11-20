# frozen_string_literal: true

require 'application_system_test_case'

class WelcomeTest < ApplicationSystemTestCase
  test 'mentors can update their profiles' do
    visit_with_auth '/current_user/edit', 'komagata'
    attach_file 'user[profile_image]', Rails.root.join('test/fixtures/files/users-avatars-komagata.jpg'), make_visible: true
    fill_in 'user[profile_name]', with: '駒形 真幸'
    fill_in 'user[profile_job]', with: 'エンジニア'
    fill_in 'user[profile_text]', with: '[株式会社ロッカ](https://lokka.jp)の代表兼エンジニア。Rubyが大好きで[怖話](https://kowabana.jp)、[フィヨルドブートキャンプ](https://bootcamp.fjord.jp)などを開発している。'
    click_on '書籍を追加'
    find("input[name*='[title]']").set('プロを目指す人のためのRuby入門 言語仕様からテスト駆動開発・デバッグ技法まで')
    find("input[name*='[url]']").set('https://www.amazon.co.jp/dp/B09MPX7SMY')
    attach_file '画像を選択', Rails.root.join('test/fixtures/files/users/books/cherry-book.jpg'), make_visible: true
    click_button '更新する'
    logout
    visit '/welcome'
    assert_selector 'img[src*="komagata.jpg"]'
    assert_text '駒形 真幸'
    assert_text 'エンジニア'
  end

  test 'administrator can update profiles of mentors' do
    user = users(:machida)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    attach_file 'user[profile_image]', Rails.root.join('test/fixtures/files/users-avatars-komagata.jpg'), make_visible: true
    fill_in 'user[profile_name]', with: '駒形 真幸'
    fill_in 'user[profile_job]', with: 'エンジニア'
    fill_in 'user[profile_text]', with: '[株式会社ロッカ](https://lokka.jp)の代表兼エンジニア。Rubyが大好きで[怖話](https://kowabana.jp)、[フィヨルドブートキャンプ](https://bootcamp.fjord.jp)などを開発している。'
    click_on '書籍を追加'
    find("input[name*='[title]']").set('プロを目指す人のためのRuby入門 言語仕様からテスト駆動開発・デバッグ技法まで')
    find("input[name*='[url]']").set('https://www.amazon.co.jp/dp/B09MPX7SMY')
    attach_file '画像を選択', Rails.root.join('test/fixtures/files/users/books/cherry-book.jpg'), make_visible: true
    click_button '更新する'
    logout
    visit '/welcome'
    assert_selector 'img[src*="komagata.jpg"]'
    assert_text '駒形 真幸'
    assert_text 'エンジニア'
  end

  test 'toggles_mentor_profile_visibility' do
    visit '/welcome'
    assert_text '駒形 真幸'
    assert_text '株式会社ロッカの代表兼エンジニア。Rubyが大好きで怖話、フィヨルドブートキャンプなどを開発している。'
    visit_with_auth edit_current_user_path, 'komagata'
    uncheck 'プロフィール公開', allow_label_click: true
    click_on '更新する'
    assert_text 'ユーザー情報を更新しました。'
    logout

    # プロフィール更新の反映を待機
    visit '/welcome'
    using_wait_time 10 do
      assert_no_text '駒形 真幸'
    end

    visit_with_auth '/welcome', 'kimura'
    assert_no_text '駒形 真幸'
  end
end
