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

  test 'verify message presence of github_account registration' do
    visit_with_auth '/', 'hajime'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'GitHubアカウントを登録してください。'

    users(:hajime).update!(github_account: 'hajime')
    refresh
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'GitHubアカウントを登録してください。'
  end

  test 'verify message presence of discord_account registration' do
    visit_with_auth '/', 'hajime'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'Discordアカウントを登録してください。'

    users(:hajime).update!(discord_account: 'hajime#1111')
    refresh
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'Discordアカウントを登録してください。'
  end

  test 'verify message presence of avatar registration' do
    visit_with_auth '/', 'hajime'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'ユーザーアイコンを登録してください。'

    path = Rails.root.join('test/fixtures/files/users/avatars/default.jpg')
    users(:hajime).avatar.attach(io: File.open(path), filename: 'hajime.jpg')
    refresh
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'ユーザーアイコンを登録してください。'
  end

  test 'verify message presence of tags registration' do
    visit_with_auth '/', 'hatsuno'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'タグを登録してください。'

    users(:hatsuno).update!(tag_list: ['猫'])
    refresh
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'タグを登録してください。'
  end

  test 'verify message presence of after_graduation_hope registration' do
    visit_with_auth '/', 'hatsuno'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを登録してください。'

    users(:hatsuno).update!(after_graduation_hope: 'IT ジェンダーギャップ問題を解決するアプリケーションを作る事業に、エンジニアとして携わる。')
    refresh
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを登録してください。'
  end

  test 'verify message presence of blog_url registration' do
    users(:hatsuno).update!(blog_url: '') # 確認のために削除
    visit_with_auth '/', 'hatsuno'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'ブログURLを登録してください。'

    users(:hatsuno).update!(blog_url: 'http://hatsuno.org')
    refresh
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'ブログURLを登録してください。'
  end

  test 'not show message of after_graduation_hope for graduated user' do
    visit_with_auth '/', 'sotugyou'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを登録してください。'
  end

  test 'not show messages of required field' do
    user = users(:hatsuno)
    # hatsuno の未入力項目を登録
    user.update!(
      tag_list: ['猫'],
      after_graduation_hope: 'IT ジェンダーギャップ問題を解決するアプリケーションを作る事業に、エンジニアとして携わる。',
      discord_account: 'hatsuno#1234'
    )
    path = Rails.root.join('test/fixtures/files/users/avatars/hatsuno.jpg')
    user.avatar.attach(io: File.open(path), filename: 'hatsuno.jpg')

    visit_with_auth '/', 'hatsuno'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text '未入力の項目'
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

  test 'set a link to the new report form at today on Nico Nico calendar' do
    visit_with_auth "/?niconico_calendar=#{Time.current.strftime('%Y-%m')}", 'hajime'
    find('.niconico-calendar').click_on Time.current.day.to_s
    assert_current_path("/reports/new?reported_on=#{Time.current.strftime('%Y-%-m-%-d')}")
  end

  test 'set a link to the new report form at past date on Nico Nico calendar' do
    visit_with_auth '/?niconico_calendar=2022-03', 'hajime'
    find('.niconico-calendar').click_on '1'
    assert_current_path('/reports/new?reported_on=2022-3-1')
  end

  test 'no link to the new report on future dates in the Nico Nico calendar' do
    visit_with_auth "/?niconico_calendar=#{Time.current.next_month.strftime('%Y-%m')}", 'hajime'
    assert_no_link(href: "/reports/new?reported_on=#{Time.current.next_month.strftime('%Y-%-m-%-d')}")
  end

  test 'show the grass for student' do
    assert users(:kimura).student?
    visit_with_auth '/', 'kimura'
    assert_selector 'h2.card-header__title', text: '学習時間'
  end

  test 'show the grass for trainee' do
    assert users(:kensyu).trainee?
    visit_with_auth '/', 'kensyu'
    assert_selector 'h2.card-header__title', text: '学習時間'
  end

  test 'not show the grass for mentor' do
    assert users(:mentormentaro).mentor?
    visit_with_auth '/', 'mentormentaro'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_selector 'h2.card-header__title', text: '学習時間'
  end

  test 'not show the grass for adviser' do
    assert users(:advijirou).adviser?
    visit_with_auth '/', 'advijirou'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_selector 'h2.card-header__title', text: '学習時間'
  end

  test 'not show the grass for admin' do
    assert users(:komagata).admin?
    visit_with_auth '/', 'komagata'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_selector 'h2.card-header__title', text: '学習時間'
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

  test 'show grass hide button for graduates' do
    visit_with_auth '/', 'kimura'
    assert_not has_button? '非表示'

    visit_with_auth '/', 'sotugyou'
    assert_selector 'h2.card-header__title', text: '学習時間'
    click_button '非表示'
    assert_no_selector 'h2.card-header__title', text: '学習時間'
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

  test 'mentor can products that are more than 5 days.' do
    visit_with_auth '/', 'mentormentaro'
    assert_text '7日以上経過（6）'
    assert_text '6日経過（1）'
    assert_text '5日経過（1）'
    assert_no_text '今日提出（48）'
  end

  test "show my wip's announcement on dashboard" do
    visit_with_auth '/', 'komagata'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-announcement' do
      assert_text 'お知らせ'
      find_link 'wipのお知らせ'
      assert_text I18n.l announcements(:announcement_wip).updated_at
    end
  end

  test "show my wip's event on dashboard" do
    visit_with_auth '/', 'kimura'
    click_link 'イベント'
    click_link 'イベント作成'
    fill_in 'event[title]', with: 'WIPのイベント'
    fill_in 'event[location]', with: 'オンライン'
    fill_in 'event[capacity]', with: 100
    fill_in 'event[start_at]', with: Time.current.next_month
    fill_in 'event[end_at]', with:  Time.current.next_month + 1.hour
    fill_in 'event[open_start_at]', with: Time.current
    fill_in 'event[open_end_at]', with: Time.current + 20.days
    fill_in 'event[description]', with: 'WIPイベント本文'
    click_button 'WIP'

    visit '/'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-event' do
      assert_text 'イベント'
      find_link 'WIPのイベント'
      event = Event.find_by(title: 'WIPのイベント')
      assert_text I18n.l event.updated_at
    end
  end

  test 'show the five latest bookmarks on dashboard' do
    visit_with_auth "/questions/#{questions(:question1).id}", 'machida'
    find('#bookmark-button').click
    visit "/pages/#{pages(:page1).id}"
    find('#bookmark-button').click
    reports = %i[report68 report69 report70 report71]
    reports.each do |report|
      visit "/reports/#{reports(report).id}"
      find('#bookmark-button').click
    end
    assert_text 'Bookmarkしました！'

    visit '/'
    assert_text '最新のブックマーク'
    find_link pages(:page1).title
    assert_text I18n.l pages(:page1).created_at, format: :long
    reports.each do |report|
      find_link reports(report).title
      assert_text I18n.l reports(report).reported_on, format: :long
    end
  end

  test 'not show bookmarks on dashboard when the user has no bookmarks' do
    visit_with_auth '/', 'machida'
    assert_current_path '/?_login_name=machida'
    assert_no_text '最新のブックマーク'
  end

  test "show my wip's page's date on dashboard" do
    visit_with_auth '/', 'komagata'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-page' do
      assert_text I18n.l pages(:page5).updated_at
    end
  end

  test "show my wip's report's date on dashboard" do
    visit_with_auth '/', 'sotugyou'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-report' do
      assert_text I18n.l reports(:report9).updated_at
    end
  end

  test "show my wip's question's date on dashboard" do
    visit_with_auth '/', 'kimura'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-question' do
      assert_text I18n.l questions(:question_for_wip).updated_at
    end
  end

  test "show my wip's product's date on dashboard" do
    visit_with_auth '/', 'kimura'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-product' do
      assert_text I18n.l products(:product5).updated_at
    end
  end
end
