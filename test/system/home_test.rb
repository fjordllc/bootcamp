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

  test 'verify message presence of github_account registration' do
    visit_with_auth '/', 'hajime'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'GitHubアカウントを登録してください。'

    users(:hajime).update!(github_account: 'hajime')
    refresh
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'GitHubアカウントを登録してください。'
  end

  test 'verify message presence of discord_profile_account_name registration' do
    visit_with_auth '/', 'hajime'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'Discordアカウントを登録してください。'

    users(:hajime).discord_profile.update!(account_name: 'hajime1111')
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

    users(:hatsuno).update!(after_graduation_hope: 'ITジェンダーギャップ問題を解決するアプリケーションを作る事業に、プログラマーとして携わる。')
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

  test 'visible announcement for activity time setup' do
    visit_with_auth '/', 'kimura'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert has_link?('活動時間を登録してください。', href: '/current_user/edit')
    click_on '活動時間を登録してください。'

    assert_selector 'h1.auth-form__title', text: '登録情報変更'
    assert_selector 'label.a-form-label', text: '主な活動予定時間'
    find('label[for="user_learning_time_frame_ids_1"]').click
    click_on '更新する'

    visit '/'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert has_no_link?('活動時間を登録してください。', href: '/current_user/edit')

    visit_with_auth '/', 'kensyu'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert has_link?('活動時間を登録してください。', href: '/current_user/edit')
    click_on '活動時間を登録してください。'

    assert_selector 'h1.auth-form__title', text: '登録情報変更'
    assert_selector 'label.a-form-label', text: '主な活動予定時間'
    find('label[for="user_learning_time_frame_ids_1"]').click
    click_on '更新する'

    visit '/'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert has_no_link?('活動時間を登録してください。', href: '/current_user/edit')
  end

  test 'not show message of after_graduation_hope for graduated user' do
    visit_with_auth '/', 'sotugyou'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを登録してください。'
  end

  test 'not show messages of required field' do
    user = users(:hatsuno)
    # hatsuno の未入力項目を登録
    user.build_discord_profile
    user.discord_profile.account_name = 'hatsuno1234'
    user.update!(
      tag_list: ['猫'],
      after_graduation_hope: 'ITジェンダーギャップ問題を解決するアプリケーションを作る事業に、プログラマーとして携わる。'
    )
    path = Rails.root.join('test/fixtures/files/users/avatars/hatsuno.jpg')
    user.avatar.attach(io: File.open(path), filename: 'hatsuno.jpg')
    LearningTimeFramesUser.create!(user:, learning_time_frame_id: 1)

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
    assert_current_path("/reports/new?reported_on=#{Time.current.strftime('%Y-%m-%d')}")
  end

  test 'set a link to the new report form at past date on Nico Nico calendar' do
    visit_with_auth '/?niconico_calendar=2022-03', 'hajime'
    find('.niconico-calendar').click_on '1'
    assert_current_path('/reports/new?reported_on=2022-03-01')
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

  test 'show job hunting events on dashboard for all user' do
    travel_to Time.zone.local(2017, 4, 2, 10, 0, 0) do
      visit_with_auth '/', 'jobseeker'
      assert_text '直近イベントの表示テスト用(当日)'
      assert_text '直近イベントの表示テスト用(翌日)'
      assert_text '就職関係かつ直近イベントの表示テスト用'
      logout

      visit_with_auth '/', 'komagata'
      assert_text '直近イベントの表示テスト用(当日)'
      assert_text '直近イベントの表示テスト用(翌日)'
      assert_text '就職関係かつ直近イベントの表示テスト用'
    end
  end

  test 'show all regular events and special events on dashbord' do
    travel_to Time.zone.local(2017, 4, 3, 8, 0, 0) do
      visit_with_auth '/', 'kimura'
      today_event_label = find('.card-list__label', text: '今日開催')
      tomorrow_event_label = find('.card-list__label', text: '明日開催')
      day_after_tomorrow_event_label = find('.card-list__label', text: '明後日開催')

      today_events_texts = [
        { category: '特別', title: '直近イベントの表示テスト用(当日)', start_at: '2017年04月03日(月) 09:00' },
        { category: '特別', title: 'kimura専用イベント', start_at: '2017年04月03日(月) 09:00' },
        { category: '輪読会', title: '月曜日開催で10:00に終了する定期イベント', start_at: '2017年04月03日(月) 09:00' },
        { category: '質問', title: '質問・雑談タイム', start_at: '2017年04月03日(月) 16:00' },
        { category: '輪読会', title: 'ダッシュボード表示確認用テスト定期イベント', start_at: '2017年04月03日(月) 21:00' },
        { category: '輪読会', title: 'ダッシュボード表示確認用テスト定期イベント', start_at: '2017年04月03日(月) 21:00' }
      ]
      tomorrow_events_texts = [
        { category: '輪読会', title: '定期イベントの検索結果テスト用', start_at: '2017年04月04日(火) 21:00' },
        { category: '特別', title: '直近イベントの表示テスト用(翌日)', start_at: '2017年04月04日(火) 22:00' }
      ]
      day_after_tomorrow_events_texts = [
        { category: '輪読会', title: 'Discord通知確認用イベント(土曜日午前8時から開催)', start_at: '2017年04月05日(水) 08:00' },
        { category: '特別', title: '直近イベントの表示テスト用(明後日)', start_at: '2017年04月05日(水) 09:00' },
        { category: '輪読会', title: '独習Git輪読会', start_at: '2017年04月05日(水) 21:00' },
        { category: '輪読会', title: '参加反映テスト用定期イベント(祝日非開催)', start_at: '2017年04月05日(水) 21:00' }
      ]

      assert_event_card(today_event_label, today_events_texts)
      assert_event_card(tomorrow_event_label, tomorrow_events_texts)
      assert_event_card(day_after_tomorrow_event_label, day_after_tomorrow_events_texts)
    end
  end

  def event_xpath(event_label, idx)
    "#{event_label.path}/following-sibling::*[#{idx + 1}][contains(@class, 'card-list-item')]"
  end

  def assert_event_card(event_label, events_texts)
    return assert_not has_selector?(:xpath, event_xpath.call(0)) if events_texts.empty?

    events_texts.each_with_index do |event_texts, idx|
      card_list_element = find(:xpath, event_xpath(event_label, idx))
      card_list_element.assert_text(event_texts[:category])
      card_list_element.assert_text(event_texts[:title])
      card_list_element.assert_text(event_texts[:start_at])
    end
    assert_events_count(event_label, events_texts.size)
  end

  def assert_events_count(event_label, count)
    assert_no_selector(:xpath, event_xpath(event_label, count))
  end

  test 'show registered to participate only participating events' do
    Event.where.not(title: ['kimura専用イベント', '直近イベントの表示テスト用(当日)']).destroy_all
    RegularEvent.where.not(title: ['ダッシュボード表示確認用テスト定期イベント', '質問・雑談タイム']).destroy_all

    travel_to Time.zone.local(2017, 4, 3, 10, 0, 0) do
      visit_with_auth '/', 'kimura'
      within all('.card-list-item')[0] do
        assert_text '直近イベントの表示テスト用(当日)'
        assert_no_text '参加'
      end
      within all('.card-list-item')[1] do
        assert_text 'kimura専用イベント'
        assert_text '参加'
      end
      within all('.card-list-item')[2] do
        assert_text '質問・雑談タイム'
        assert_no_text '参加'
      end
      within all('.card-list-item')[3] do
        assert_text 'ダッシュボード表示確認用テスト定期イベント'
        assert_text '参加'
      end
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

  test 'mentor can products that are more than 4 days.' do
    visit_with_auth '/', 'mentormentaro'
    assert_text '6日以上経過（7）'
    assert_text '5日経過（1）'
    assert_text '4日経過（1）'
  end

  test 'display counts of passed almost 5days' do
    visit_with_auth '/', 'mentormentaro'
    assert_text "2件の提出物が、\n8時間以内に4日経過に到達します。"

    products(:product70).update!(checker: users(:mentormentaro))
    visit current_path
    assert_text "1件の提出物が、\n8時間以内に4日経過に到達します。"

    products(:product71).update!(checker: users(:mentormentaro))
    visit current_path
    assert_text "しばらく4日経過に到達する\n提出物はありません。"
  end

  test 'work link of passed almost 5days' do
    visit_with_auth '/', 'mentormentaro'
    find('.under-cards').click
    assert_current_path('/products/unassigned')
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
    click_link '特別イベント作成'
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
    visit "/talks/#{talks(:talk1).id}"
    find('#bookmark-button').click
    reports = %i[report68 report69 report70]
    reports.each do |report|
      visit "/reports/#{reports(report).id}"
      find('#bookmark-button').click
    end
    assert_text 'Bookmarkしました！'

    visit '/'
    assert_text '最新のブックマーク'
    find_link pages(:page1).title
    assert_text I18n.l pages(:page1).created_at, format: :long
    user = talks(:talk1).user
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    find_link "#{decorated_user.long_name} さんの相談部屋"
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
    Bookmark.destroy_all

    visit_with_auth '/', 'kimura'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-question' do
      assert_text I18n.l questions(:question_for_wip).updated_at
    end
  end

  test "show my wip's product's date on dashboard" do
    Bookmark.destroy_all

    visit_with_auth '/', 'kimura'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-product' do
      assert_text I18n.l products(:product5).updated_at
    end
  end

  test 'show trainee lists for adviser belonging a company' do
    visit_with_auth '/', 'senpai'
    assert_selector 'h2.card-header__title', text: '研修生'
  end

  test 'not show trainee lists for student' do
    visit_with_auth '/', 'kimura'
    assert_no_selector 'h2.card-header__title', text: '研修生'
  end

  test 'delete bookmark for latest bookmarks on dashboard' do
    visit_with_auth '/', 'kimura'

    reports = %i[report68 report69 report70 report71]
    reports.each do |report|
      visit "/reports/#{reports(report).id}"
      find('#bookmark-button').click
    end
    assert_text 'Bookmarkしました！'

    visit '/'
    first('.spec-bookmark-edit').click
    first('.js-bookmark-delete-button').click
    assert_text 'ブックマークを削除しました。'
    assert_no_text '名前の長いメンター用'
  end

  test 'not show trainee lists for adviser when adviser does not have same company trainees' do
    visit_with_auth '/', 'advisernocolleaguetrainee'
    assert_text '現在、ユーザの企業に登録しないで株式会社は研修を利用していません。'
  end

  test 'show trainee reports to adviser belonging to the same company on dashboard' do
    visit_with_auth '/', 'senpai'
    assert_selector 'h2.card-header__title', text: '研修生の最新の日報'
  end

  test 'not show trainee reports to anyone except adviser on dashboard' do
    visit_with_auth '/', 'kimura'
    assert_no_selector 'h2.card-header__title', text: '研修生の最新の日報'
  end

  test 'display message if no product after 5 days' do
    Product.delete_all
    user = users(:kimura)
    practice = practices(:practice1)
    Product.create(practice_id: practice.id, user_id: user.id, body: 'test body', published_at: Time.current.ago(1.day))
    travel_to Time.current do
      visit_with_auth '/', 'komagata'
      assert_text 'しばらく4日経過に到達する'
      assert_text '提出物はありません。'
    end
  end

  test 'shows event status even if it is not held on holidays' do
    Event.destroy_all
    RegularEvent.where.not(title: 'ダッシュボード表示確認用テスト定期イベント(祝日非開催)').destroy_all

    travel_to Time.zone.parse('2023-09-18') do
      visit_with_auth '/', 'hatsuno'
      today_event_label = find('.card-list__label', text: '今日開催')
      today_events_texts = [
        {
          category: '休み',
          title: 'ダッシュボード表示確認用テスト定期イベント(祝日非開催)',
          start_at: '09月18日はお休みです。'
        }
      ]
      assert_event_card(today_event_label, today_events_texts)
    end
  end

  test 'shows event status when it is held on weekdays' do
    Event.destroy_all
    RegularEvent.where.not(title: 'ダッシュボード表示確認用テスト定期イベント(祝日非開催)').destroy_all

    travel_to Time.zone.parse('2023-09-25') do
      visit_with_auth '/', 'hatsuno'
      today_event_label = find('.card-list__label', text: '今日開催')
      today_events_texts = [
        {
          category: '輪読会',
          title: 'ダッシュボード表示確認用テスト定期イベント(祝日非開催)',
          start_at: '2023年09月25日(月) 21:00'
        }
      ]
      assert_event_card(today_event_label, today_events_texts)
    end
  end

  test 'show job hunting on job hunting related events' do
    Event.where.not(title: ['就職関係かつ直近イベントの表示テスト用']).destroy_all
    RegularEvent.destroy_all

    travel_to Time.zone.local(2017, 4, 2, 10, 0, 0) do
      visit_with_auth '/', 'kimura'
      within all('.card-list-item')[0] do
        assert_text '就職関係かつ直近イベントの表示テスト用'
        assert_text '就活関連イベント'
      end
    end
  end

  test 'show the latest reports for students' do
    visit_with_auth '/', 'hajime'
    assert_text '最新のみんなの日報'
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
