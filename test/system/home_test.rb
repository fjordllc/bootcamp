# frozen_string_literal: true

require 'application_system_test_case'

class HomeTest < ApplicationSystemTestCase
  test 'GET / without sign in' do
    logout
    visit '/'
    assert_equal 'FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /' do
    visit_with_auth '/', 'komagata'
    assert_equal 'ダッシュボード | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET / without github account ' do
    visit_with_auth '/', 'hajime'
    within('.card-list__item-link.is-github_account') do
      assert_text 'GitHubアカウントを登録してください。'
    end
  end

  test 'GET / with github account' do
    user = users(:hajime)
    user.update!(github_account: 'hajime')
    visit_with_auth '/', 'hajime'
    assert_no_selector '.card-list__item-link.is-github_account'
  end

  test 'GET / without discord_account' do
    visit_with_auth '/', 'hajime'
    within('.card-list__item-link.is-discord_account') do
      assert_text 'Discordアカウントを登録してください。'
    end
  end

  test 'GET / with discord_account' do
    user = users(:hajime)
    user.update!(discord_account: 'hajime#1111')
    visit_with_auth '/', 'hajime'
    assert_no_selector '.card-list__item-link.is-discord_account'
  end

  test 'show latest announcements on dashboard' do
    visit_with_auth '/', 'hajime'
    assert_text '後から公開されたお知らせ'
    assert_no_text 'wipのお知らせ'
  end

  test 'show the Nico Nico calendar for students' do
    visit_with_auth '/', 'hajime'
    assert_text 'ニコニコカレンダー'
  end

  test 'show the Nico Nico calendar for graduates' do
    visit_with_auth '/', 'sotugyou'
    assert_text 'ニコニコカレンダー'
  end

  test 'not show the Nico Nico calendar for administrators' do
    visit_with_auth '/', 'komagata'
    assert_no_text 'ニコニコカレンダー'
  end

  test 'show the Nico Nico calendar for trainees' do
    visit_with_auth '/', 'kensyu'
    assert_text 'ニコニコカレンダー'
  end

  test 'show Nico Nico calendar page that matches URL params' do
    visit_with_auth '/?niconico_calendar=2020-01', 'hajime'
    find('.niconico-calendar-nav').assert_text '2020年1月'
  end

  test "show current month's page of Nico Nico calendar when future date is specified in URL params" do
    visit_with_auth "/?niconico_calendar=#{Time.current.next_month.strftime('%Y-%m')}", 'hajime'
    find('.niconico-calendar-nav').assert_text Time.current.strftime('%Y年%-m月')
  end

  test 'keep Nico Nico calendar page even when leave dashboard' do
    visit_with_auth '/', 'hajime'
    find('.niconico-calendar-nav__previous').click
    find('.niconico-calendar-nav').assert_text 1.month.ago.strftime('%Y年%-m月')
    find('.niconico-calendar').click_link href: /reports/, match: :first
    go_back
    find('.niconico-calendar-nav').assert_text 1.month.ago.strftime('%Y年%-m月')
    assert_current_path(/niconico_calendar=#{1.month.ago.strftime('%Y-%m')}/)
  end

  test 'show the grass for student and trainee' do
    visit_with_auth '/', 'kimura'
    # 生徒は学習時間の草を表示する
    assert_text '学習時間'
    logout

    # 研修生は学習時間の草を表示する
    visit_with_auth '/', 'kensyu'
    assert_text '学習時間'
  end

  test 'not show the grass for mentor, adviser, and admin' do
    # メンターは学習時間の草を表示しない
    visit_with_auth '/', 'yamada'
    assert_no_text '学習時間'
    logout

    # アドバイザーは学習時間の草を表示しない
    visit_with_auth '/', 'advijirou'
    assert_no_text '学習時間'
    logout

    # 管理者は学習時間の草を表示しない
    visit_with_auth '/', 'komagata'
    assert_no_text '学習時間'
  end

  test 'show test events on dashboard' do
    travel_to Time.zone.local(2017, 4, 1, 10, 0, 0) do
      visit_with_auth '/', 'komagata'
      assert_text '直近イベントの表示テスト用(当日)'
      assert_text '直近イベントの表示テスト用(翌日)'
    end
  end

  test 'show job events on dashboard for only job seeker' do
    travel_to Time.zone.local(2017, 4, 1, 10, 0, 0) do
      visit_with_auth '/', 'jobseeker'
      assert_text '直近イベントの表示テスト用(当日)'
      assert_text '直近イベントの表示テスト用(翌日)'
      assert_text '就職関係かつ直近イベントの表示テスト用'
      logout

      visit_with_auth '/', 'komagata'
      assert_text '直近イベントの表示テスト用(当日)'
      assert_text '直近イベントの表示テスト用(翌日)'
      assert_no_text '就職関係かつ直近イベントの表示テスト用'
    end
  end
end
