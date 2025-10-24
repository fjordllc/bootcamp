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
    create_report_as('muryou', '初日報です', '初日報の内容です', save_as_wip: false)

    notification_message = 'muryouさんがはじめての日報を書きました！'
    visit_with_auth '/notifications', 'machida'
    find('#notifications.loaded')
    assert_text notification_message
    logout

    visit_with_auth '/notifications', 'kimura'
    find('#notifications.loaded')
    assert_no_text notification_message
    logout

    visit_with_auth '/notifications', 'advijirou'
    find('#notifications.loaded')
    assert_no_text notification_message
    logout

    visit_with_auth '/notifications', 'sotugyou'
    find('#notifications.loaded')
    assert_no_text notification_message
    logout
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
    assert_selector('h2.page-header__title', text: '日報・みんなのブログ')
    logout

    visit_with_auth '/notifications', 'komagata'
    assert_no_text 'kimuraさんがはじめての日報を書きました！'
    logout
  end

  test 'no notification if report already posted' do
    # 他のテストの通知に影響を受けないよう、テスト実行前に通知を削除する
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'
    logout

    create_report_as('kimura', 'test title', 'test', save_as_wip: false)

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_text '未読の通知はありません'
    logout
  end

  def assert_notify_only_when_report_is_initially_posted(
    notification_message,
    author_login_name,
    received_user_login_name,
    title,
    description
  )

    report_id = create_report_as(author_login_name, title, description, save_as_wip: true)

    # 日報を WIP -> 提出 -> 内容変更 の流れで作成・更新し通知の有無を確認する
    visit_with_auth notifications_path(status: 'unread'), received_user_login_name
    assert_no_selector(notification_selector,
                       text: notification_message)
    logout

    update_report_as_author(report_id, title, description, save_as_wip: false)
    visit_with_auth notifications_path(status: 'unread'), received_user_login_name
    assert_selector(notification_selector,
                    text: notification_message)
    click_link(notification_message)
    assert_equal current_path, report_path(report_id)
    logout

    update_report_as_author(report_id, title, description, save_as_wip: false)
    visit_with_auth notifications_path(status: 'unread'), received_user_login_name
    assert_no_selector(notification_selector,
                       text: notification_message)
    logout
  end

  test 'notify company advisor only when report is initially posted' do
    kensyu_login_name = 'kensyu'
    advisor_login_name = 'senpai'
    title = '研修生が日報を作成し提出した時'
    description = 'アドバイザーに通知を飛ばす'
    notification_message = make_write_report_notification_message(
      kensyu_login_name, title
    )

    assert_notify_only_when_report_is_initially_posted(
      notification_message,
      kensyu_login_name,
      advisor_login_name,
      title,
      description
    )
  end

  test 'notify follower only when report is initially posted' do
    following = Following.first
    followed_user_login_name = User.find(following.followed_id).login_name
    follower_user_login_name = User.find(following.follower_id).login_name
    title = '初めて提出した時だけ'
    description = 'フォローされているユーザーに通知を飛ばす'
    notification_message = make_write_report_notification_message(
      followed_user_login_name, title
    )

    assert_notify_only_when_report_is_initially_posted(
      notification_message,
      followed_user_login_name,
      follower_user_login_name,
      title,
      description
    )
  end

  test 'notify mention target only when report is initially posted' do
    mention_target_login_name = 'kimura'
    author_login_name = 'machida'
    title = '初めて提出したら、'
    description = "@#{mention_target_login_name} に通知する"

    assert_notify_only_when_report_is_initially_posted(
      make_mention_notification_message(author_login_name),
      author_login_name,
      mention_target_login_name,
      title,
      description
    )
  end

  test 'notify user only when first report is initially posted' do
    check_notification_login_name = 'machida'
    author_login_name = 'nippounashi'
    title = '初めての日報を提出したら'
    description = 'ユーザーに通知をする'
    assert_notify_only_when_report_is_initially_posted(
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
    logout

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
    logout

    visit_with_auth '/notifications', mentor

    within first('.card-list-item.is-unread') do
      assert_text "#{student}さんが2回連続でsadアイコンの日報を提出しました。"
    end
    logout
  end

  test 'mentioning in code blocks and inline code does not work' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'
    logout

    mention_in_code = '```@mentor```, ` @mentor `'
    create_report_as('kimura', 'コードブロック内でメンション', mention_in_code, save_as_wip: false)

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_text '未読の通知はありません'
    logout
  end
end
