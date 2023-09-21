# frozen_string_literal: true

require 'application_system_test_case'

class Notification::ReportsTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'the first daily report notification is sent only to mentors' do
    login_user 'muryou', 'testtest'
    create_report('初日報です', '初日報の内容です', false)
    logout

    notification_message = 'muryouさんがはじめての日報を書きました！'
    visit_with_auth '/notifications', 'machida'
    find('#notifications.loaded', wait: 10)
    assert_text notification_message

    visit_with_auth '/notifications', 'kimura'
    find('#notifications.loaded', wait: 10)
    assert_no_text notification_message

    visit_with_auth '/notifications', 'advijirou'
    find('#notifications.loaded', wait: 10)
    assert_no_text notification_message

    visit_with_auth '/notifications', 'sotugyou'
    find('#notifications.loaded', wait: 10)
    assert_no_text notification_message
  end

  test 'notify when WIP report submitted' do
    Report.all.each(&:destroy)

    visit_with_auth '/reports/new', 'kensyu'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
      fill_in('report[reported_on]', with: Time.current)
    end
    within('.learning-time__started-at') do
      select '07'
      select '30'
    end
    within('.learning-time__finished-at') do
      select '08'
      select '30'
    end

    click_button 'WIP'
    assert_text '日報をWIPとして保存しました。'

    visit_with_auth '/notifications', 'komagata'
    assert_no_text 'kensyuさんがはじめての日報を書きました！'

    visit_with_auth "/users/#{users(:kensyu).id}/reports", 'kensyu'
    click_link 'test title'
    click_link '内容修正'
    click_button '提出'
    assert_text '日報を保存しました。'

    visit_with_auth '/notifications', 'komagata'
    assert_text 'kensyuさんがはじめての日報を書きました！'
  end

  test "don't notify when first report is WIP" do
    Report.destroy_all

    visit_with_auth '/reports/new', 'kensyu'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
      fill_in('report[reported_on]', with: Time.current)
    end
    within('.learning-time__started-at') do
      select '07'
      select '30'
    end
    within('.learning-time__finished-at') do
      select '08'
      select '30'
    end

    click_button 'WIP'
    assert_text '日報をWIPとして保存しました。'

    visit_with_auth '/notifications', 'komagata'
    assert_no_text 'kensyuさんがはじめての日報を書きました！'
  end

  test 'delete report with notification' do
    report = users(:kimura).reports.create!(
      title: 'test title',
      description: 'test.',
      reported_on: Date.current
    )

    Notification.create!(
      kind: 7,
      user: users(:komagata),
      sender: users(:kimura),
      message: "#{users(:kimura).login_name}さんがはじめての日報を書きました！",
      link: "/reports/#{report.id}",
      read: false
    )

    visit_with_auth "/reports/#{report.id}", 'kimura'

    find 'h2', text: 'コメント'
    find 'div.container div.user-icons > ul.user-icons__items', visible: :all
    accept_confirm do
      click_link '削除'
    end
    assert_text '日報を削除しました。'

    visit_with_auth '/notifications', 'komagata'
    assert_no_text 'kimuraさんがはじめての日報を書きました！'
  end

  test '複数の日報が投稿されているときは通知が飛ばない' do
    # 他のテストの通知に影響を受けないよう、テスト実行前に通知を削除する
    visit_with_auth '/notifications', 'muryou'
    click_link '全て既読にする'

    visit_with_auth '/reports', 'komagata'
    click_link '日報作成'

    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
    end

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')

    click_button '提出'
    logout

    login_user 'muryou', 'testtest'
    assert page.has_css?('.has-no-count')
  end

  def assert_notify_only_at_first_published_of_report(
    notification_message,
    author_login_name,
    recived_user_login_name,
    title,
    description
  )
    exists_notification_in_unread = -> { exists_unread_notification?(notification_message) }
    report_id = nil # injectで書く方法もあるがそうすると読み辛い

    3.times do |time|
      login_user author_login_name, 'testtest'
      # WIP => 提出 => 提出のように日報を書く
      if time.zero?
        report_id = create_report(title, description, true)
      else
        update_report(report_id, title, description, false)
      end
      logout

      login_user recived_user_login_name, 'testtest'
      if time == 1
        assert exists_notification_in_unread.call
        link_to_page_by_unread_notification(notification_message)
        assert_equal current_path, report_path(report_id)
      else
        assert_not exists_notification_in_unread.call
      end
      logout
    end
  end

  test '研修生が日報を作成し提出した時、企業のアドバイザーに通知する' do
    kensyu_login_name = 'kensyu'
    advisor_login_name = 'senpai'
    title = '研修生が日報を作成し提出した時'
    description = 'アドバイザーに通知を飛ばす'
    notification_message = make_write_report_notification_message(
      kensyu_login_name, title
    )
    assert_notify_only_at_first_published_of_report(
      notification_message,
      kensyu_login_name,
      advisor_login_name,
      title,
      description
    )
  end

  test '初めて提出した時だけ、フォローされているユーザーに通知する' do
    following = Following.first
    followed_user_login_name = User.find(following.followed_id).login_name
    follower_user_login_name = User.find(following.follower_id).login_name
    title = '初めて提出した時だけ'
    description = 'フォローされているユーザーに通知を飛ばす'
    notification_message = make_write_report_notification_message(
      followed_user_login_name, title
    )
    assert_notify_only_at_first_published_of_report(
      notification_message,
      followed_user_login_name,
      follower_user_login_name,
      title,
      description
    )
  end

  test '初めて提出した時だけ、メンション通知する' do
    mention_target_login_name = 'kimura'
    author_login_name = 'machida'
    title = '初めて提出したら、'
    description = "@#{mention_target_login_name} に通知する"
    assert_notify_only_at_first_published_of_report(
      make_mention_notification_message(author_login_name),
      author_login_name,
      mention_target_login_name,
      title,
      description
    )
  end

  test '初日報は初めて公開した時だけ通知する' do
    check_notification_login_name = 'machida'
    author_login_name = 'nippounashi'
    title = '初めての日報を提出したら'
    description = 'ユーザーに通知をする'
    assert_notify_only_at_first_published_of_report(
      "#{author_login_name}さんがはじめての日報を書きました！",
      author_login_name,
      check_notification_login_name,
      title,
      description
    )
  end

  test 'notify to mentors when a student submitted reports with sad icon at twice in a row' do
    student = 'kimura'
    mentor = 'mentormentaro'

    visit_with_auth '/reports', student

    click_link '日報作成'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title 1')
      fill_in('report[description]', with: 'test 1')
      fill_in('report[reported_on]', with: Date.current.prev_day)
      find('#sad').click
    end
    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')
    click_button '提出'
    find('.modal-header__close').click

    visit_with_auth '/reports', student

    click_link '日報作成'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title 2')
      fill_in('report[description]', with: 'test 2')
      fill_in('report[reported_on]', with: Date.current)
      find('#sad').click
    end
    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')
    click_button '提出'
    find('.modal-header__close').click

    visit_with_auth '/notifications', mentor

    within first('.card-list-item.is-unread') do
      assert_text "#{student}さんが2回連続でsadアイコンの日報を提出しました。"
    end
  end
end
