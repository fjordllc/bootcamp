# frozen_string_literal: true

require 'application_system_test_case'

class HomeTest < ApplicationSystemTestCase
  test 'GET / without sign in' do
    logout
    visit '/'
    assert_equal 'プログラミングスクール FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /' do
    visit_with_auth '/', 'komagata'
    assert_equal 'ダッシュボード | FBC', title
  end

  test 'show latest announcements on dashboard' do
    visit_with_auth '/', 'hajime'
    assert_text '後から公開されたお知らせ'
    assert_no_text 'wipのお知らせ'
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

  test 'show the latest reports for students' do
    visit_with_auth '/', 'hajime'
    assert_text '最新のみんなの日報'
  end

  test 'toggles mentor profile visibility' do
    visit '/'
    assert_text '駒形 真幸'
    assert_text '株式会社ロッカの代表兼エンジニア。Rubyが大好きで怖話、フィヨルドブートキャンプなどを開発している。'
    visit_with_auth edit_current_user_path, 'komagata'
    uncheck 'プロフィール公開', allow_label_click: true
    click_on '更新する'
    assert_text 'ユーザー情報を更新しました。'
    logout

    # プロフィール更新の反映を待機
    visit '/'
    using_wait_time 10 do
      assert_no_text '駒形 真幸'
      assert_no_text '株式会社ロッカの代表兼エンジニア。Rubyが大好きで怖話、フィヨルドブートキャンプなどを開発している。'
    end
  end

  test 'toggles study streak visibility' do
    user = users(:hajime)
    visit_with_auth '/', 'hajime'

    initial_show_study_streak = user.show_study_streak

    assert_no_selector '.card-body', text: '現在の連続記録'
    assert_no_selector '.card-body', text: '連続最高記録'
    assert_not find('#toggle', visible: false).checked?
    find('label.a-on-off-checkbox').click

    assert_equal !initial_show_study_streak, user.reload.show_study_streak
    assert_selector '.card-body', text: '現在の連続記録'
    assert_selector '.card-body', text: '連続最高記録'
    assert find('#toggle', visible: false).checked?
    find('label.a-on-off-checkbox').click
  end

  test 'not show study streak toggle when no learning reports exist' do
    assert_not users(:kensyu).reports_with_learning_times.present?
    visit_with_auth '/', 'kensyu'
    assert_no_selector 'label.a-on-off-checkbox'
    logout
    assert users(:hajime).reports_with_learning_times.present?
    visit_with_auth '/', 'hajime'
    assert_selector 'label.a-on-off-checkbox'
  end
end
