# frozen_string_literal: true

require 'application_system_test_case'

class WelcomeTest < ApplicationSystemTestCase
  test 'GET /welcome' do
    visit '/welcome'
    assert_equal 'FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /practices' do
    visit '/practices'
    assert_equal '学習内容 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /pricing' do
    visit '/pricing'
    assert_equal '料金 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /training' do
    visit '/training'
    assert_equal '法人利用 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /articles' do
    visit '/articles'
    assert_equal 'ブログ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /faq' do
    visit '/faq'
    assert_equal 'FAQ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /tos' do
    visit '/tos'
    assert_equal '利用規約 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /pp' do
    visit '/pp'
    assert_equal 'プライバシーポリシー | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /law' do
    visit '/law'
    assert_equal '特定商取引法に基づく表記 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /coc' do
    visit '/coc'
    assert_equal 'アンチハラスメントポリシー | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'mentors can update their profiles' do
    visit_with_auth '/current_user/edit', 'komagata'
    attach_file 'user[profile_image]', Rails.root.join('test/fixtures/files/users/avatars/komagata.jpg'), make_visible: true
    fill_in 'user[profile_name]', with: '駒形 真幸'
    fill_in 'user[profile_job]', with: 'プログラマー'
    fill_in 'user[profile_text]', with: '[株式会社フィヨルド](https://fjord.jp)の代表兼プログラマー。Rubyが大好きで[怖話](https://kowabana.jp)、[フィヨルドブートキャンプ](https://bootcamp.fjord.jp)などを開発している。'
    click_button '更新する'
    logout
    visit '/welcome'
    assert_selector 'img[src*="komagata.jpg"]'
    assert_text '駒形 真幸'
    assert_text 'プログラマー'
    assert_text '株式会社フィヨルドの代表兼プログラマー。Rubyが大好きで怖話、フィヨルドブートキャンプなどを開発している。'
  end

  test 'administrator can update profiles of mentors' do
    user = users(:machida)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    attach_file 'user[profile_image]', Rails.root.join('test/fixtures/files/users/avatars/komagata.jpg'), make_visible: true
    fill_in 'user[profile_name]', with: '駒形 真幸'
    fill_in 'user[profile_job]', with: 'プログラマー'
    fill_in 'user[profile_text]', with: '[株式会社フィヨルド](https://fjord.jp)の代表兼プログラマー。Rubyが大好きで[怖話](https://kowabana.jp)、[フィヨルドブートキャンプ](https://bootcamp.fjord.jp)などを開発している。'
    click_button '更新する'
    logout
    visit '/welcome'
    assert_selector 'img[src*="komagata.jpg"]'
    assert_text '駒形 真幸'
    assert_text 'プログラマー'
    assert_text '株式会社フィヨルドの代表兼プログラマー。Rubyが大好きで怖話、フィヨルドブートキャンプなどを開発している。'
  end
end
