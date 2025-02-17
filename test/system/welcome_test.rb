# frozen_string_literal: true

require 'application_system_test_case'

class WelcomeTest < ApplicationSystemTestCase
  setup do
    articles_with_dates = {
      article21: '2024-02-01 09:00:00',
      article22: '2024-02-02 09:00:00',
      article23: '2024-02-03 09:00:00',
      article24: '2024-02-04 09:00:00',
      article25: '2024-02-05 09:00:00',
      article26: '2024-02-06 09:00:00',
      article27: '2024-02-07 09:00:00'
    }
    articles_with_dates.each do |key, datetime|
      article = articles(key)
      article.tag_list.add('注目の記事')
      time = Time.zone.parse(datetime)
      article.published_at = time
      article.created_at = time
      article.save!
    end
  end

  test 'GET /welcome' do
    visit '/welcome'
    assert_equal 'プログラミングスクール FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='FJORD BOOT CAMP（フィヨルドブートキャンプ）']", visible: false
    assert_selector "meta[name='twitter:title'][content='FJORD BOOT CAMP（フィヨルドブートキャンプ）']", visible: false
  end

  test 'GET /practices' do
    visit '/practices'
    assert_equal '学習内容 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='学習内容']", visible: false
    assert_selector "meta[name='twitter:title'][content='学習内容']", visible: false
  end

  test 'GET /pricing' do
    visit '/pricing'
    assert_equal '料金 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='料金']", visible: false
    assert_selector "meta[name='twitter:title'][content='料金']", visible: false
  end

  test 'GET /training' do
    visit '/training'
    assert_equal '法人利用 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='法人利用']", visible: false
    assert_selector "meta[name='twitter:title'][content='法人利用']", visible: false
  end

  test 'GET /articles' do
    visit '/articles'
    assert_equal 'ブログ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='ブログ']", visible: false
    assert_selector "meta[name='twitter:title'][content='ブログ']", visible: false
  end

  test 'GET /faq' do
    visit '/faq'
    assert_equal 'FAQ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='FAQ']", visible: false
    assert_selector "meta[name='twitter:title'][content='FAQ']", visible: false
  end

  test 'GET /buzz' do
    visit '/buzz'
    assert_equal '紹介・言及記事 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='紹介・言及記事']", visible: false
    assert_selector "meta[name='twitter:title'][content='紹介・言及記事']", visible: false
  end

  test 'GET /tos' do
    visit '/tos'
    assert_equal '利用規約 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='利用規約']", visible: false
    assert_selector "meta[name='twitter:title'][content='利用規約']", visible: false
  end

  test 'GET /pp' do
    visit '/pp'
    assert_equal 'プライバシーポリシー | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='プライバシーポリシー']", visible: false
    assert_selector "meta[name='twitter:title'][content='プライバシーポリシー']", visible: false
  end

  test 'GET /law' do
    visit '/law'
    assert_equal '特定商取引法に基づく表記 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='特定商取引法に基づく表記']", visible: false
    assert_selector "meta[name='twitter:title'][content='特定商取引法に基づく表記']", visible: false
  end

  test 'GET /coc' do
    visit '/coc'
    assert_equal 'アンチハラスメントポリシー | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='アンチハラスメントポリシー']", visible: false
    assert_selector "meta[name='twitter:title'][content='アンチハラスメントポリシー']", visible: false
  end

  test 'GET /alumni_voices' do
    visit '/alumni_voices'
    assert_equal '卒業生の声 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='卒業生の声']", visible: false
    assert_selector "meta[name='twitter:title'][content='卒業生の声']", visible: false
  end

  test 'get /choose_courses' do
    visit '/choose_courses'
    assert_equal 'コース選択 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_selector "meta[property='og:title'][content='コース選択']", visible: false
    assert_selector "meta[name='twitter:title'][content='コース選択']", visible: false
  end

  test 'mentors can update their profiles' do
    visit_with_auth '/current_user/edit', 'komagata'
    attach_file 'user[profile_image]', Rails.root.join('test/fixtures/files/users/avatars/komagata.jpg'), make_visible: true
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
    attach_file 'user[profile_image]', Rails.root.join('test/fixtures/files/users/avatars/komagata.jpg'), make_visible: true
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
    visit '/welcome'
    assert_no_text '駒形 真幸'
    visit_with_auth '/welcome', 'kimura'
    assert_no_text '駒形 真幸'
  end

  test '6 articles with a specific tag are displayed in order of published_at' do
    visit '/welcome'
    article_dates = all('.articles-item__published-at').map(&:text)
    expected_dates = [
      '2024年02月07日(水) 09:00',
      '2024年02月06日(火) 09:00',
      '2024年02月05日(月) 09:00',
      '2024年02月04日(日) 09:00',
      '2024年02月03日(土) 09:00',
      '2024年02月02日(金) 09:00'
    ]
    assert_equal expected_dates, article_dates
  end
end
