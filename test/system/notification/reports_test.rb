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
    find('#notifications.loaded')
    assert_text notification_message

    visit_with_auth '/notifications', 'kimura'
    find('#notifications.loaded')
    assert_no_text notification_message

    visit_with_auth '/notifications', 'advijirou'
    find('#notifications.loaded')
    assert_no_text notification_message

    visit_with_auth '/notifications', 'sotugyou'
    find('#notifications.loaded')
    assert_no_text notification_message
  end

  test 'notify when WIP report submitted' do
    Report.all.find_each(&:destroy)

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

  test 'no notification if report already posted' do
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

    visit_with_auth '/notifications?status=unread', 'muryou'
    assert_text '未読の通知はありません'
  end

  test 'notify company advisor only when report is initially posted' do
    training_student_name = 'kensyu'
    advisor_name = 'senpai'
    title = '研修生が日報を作成し提出した時'
    description = 'アドバイザーに通知を飛ばす'
    message = make_write_report_notification_message(
      training_student_name, title
    )

    report_id = create_report_as(training_student_name, title, description, true)
    visit_with_auth notifications_path(status: 'unread'), advisor_name
    assert_no_selector(notification_selector,
                       text: message)
    logout

    update_report_as(report_id, training_student_name, title, description, false)
    visit_with_auth notifications_path(status: 'unread'), advisor_name
    assert_selector(notification_selector,
                    text: message)
    click_link(message)
    assert_equal current_path, report_path(report_id)
    logout

    update_report_as(report_id, training_student_name, title, description, false)
    visit_with_auth notifications_path(status: 'unread'), advisor_name
    assert_no_selector(notification_selector,
                       text: message)
  end

  test 'notify follower only when report is initially posted' do
    following = followings(:following1)
    followed_login_name = User.find(following.followed_id).login_name
    follower_login_name = User.find(following.follower_id).login_name
    title = 'followedが初めて日報を提出した時'
    description = 'フォローしているユーザーに通知を飛ばす'
    message = make_write_report_notification_message(
      followed_login_name, title
    )

    report_id = create_report_as(followed_login_name, title, description, true)
    visit_with_auth notifications_path(status: 'unread'), follower_login_name
    assert_no_selector(notification_selector,
                       text: message)
    logout

    update_report_as(report_id, followed_login_name, title, description, false)
    visit_with_auth notifications_path(status: 'unread'), follower_login_name
    assert_selector(notification_selector,
                    text: message)
    click_link(message)
    assert_equal current_path, report_path(report_id)
    logout

    update_report_as(report_id, followed_login_name, title, description, false)
    visit_with_auth notifications_path(status: 'unread'), follower_login_name
    assert_no_selector(notification_selector,
                       text: message)
  end

  test 'notify mention target only when report is initially posted' do
    mention_target_name = 'kimura'
    author_name = 'machida'
    description = "@#{mention_target_name} に通知する"
    message = make_mention_notification_message(author_name)

    report_id = create_report_as(author_name, 'Step1:wipで保存', description, true)
    visit_with_auth notifications_path(status: 'unread'), mention_target_name
    assert_no_selector(notification_selector,
                       text: message)
    logout

    update_report_as(report_id, author_name, 'Step2:提出ボタン押す', description, false)
    visit_with_auth notifications_path(status: 'unread'), mention_target_name
    assert_selector(notification_selector,
                    text: message)
    click_link(message)
    assert_equal current_path, report_path(report_id)
    logout

    update_report_as(report_id, author_name, 'Step3:再度提出ボタン押す', description, false)
    visit_with_auth notifications_path(status: 'unread'), mention_target_name
    assert_no_selector(notification_selector,
                       text: message)
  end

  test 'notify user only when first report is initially posted' do
    checker_login_name = 'machida'
    author_login_name = 'nippounashi'
    title = '初めての日報を提出した時'
    description = 'ユーザーに通知をする'
    message = first_report_message(author_login_name)

    delete_all_report(author_login_name)
    report_id = create_report_as(author_login_name, title, description, true)
    visit_with_auth notifications_path(status: 'unread'), checker_login_name
    assert_no_selector(notification_selector,
                       text: message)
    logout

    update_report_as(report_id, author_login_name, title, description, false)
    visit_with_auth notifications_path(status: 'unread'), checker_login_name
    assert_selector(notification_selector,
                    text: message)
    click_link(message)
    assert_equal current_path, report_path(report_id)
    logout

    update_report_as(report_id, author_login_name, title, description, false)
    visit_with_auth notifications_path(status: 'unread'), checker_login_name
    assert_no_selector(notification_selector,
                       text: message)
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

  test 'mentioning in code blocks and inline code does not work' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    visit_with_auth '/reports', 'kimura'
    click_link '日報作成'

    mention_in_code = '```@mentor```, ` @mentor `'
    within('form[name=report]') do
      fill_in('report[title]', with: 'コードブロック内でメンション')
      fill_in('report[description]', with: mention_in_code)
    end

    within('.learning-time__started-at') do
      select '07'
      select '30'
    end
    within('.learning-time__finished-at') do
      select '08'
      select '30'
    end

    click_button '提出'
    logout

    visit_with_auth '/notifications?status=unread', 'komagata'
    assert_text '未読の通知はありません'
  end
end
