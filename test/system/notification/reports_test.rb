# frozen_string_literal: true

require 'application_system_test_case'

class Notification::ReportsTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/introduction')
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'the first daily report notification is sent only to mentors' do
    login_user 'muryou', 'testtest'
    create_report('初日報です', '初日報の内容です', false)
    logout

    notification_message = 'muryouさんがはじめての日報を書きました！'

    notifications = Notification.where(user: users(:machida), kind: Notification.kinds[:first_report])
    assert(notifications.any? { |n| n.message.include?(notification_message) })

    notifications = Notification.where(user: users(:kimura), kind: Notification.kinds[:first_report])
    assert_not(notifications.any? { |n| n.message.include?(notification_message) })

    notifications = Notification.where(user: users(:advijirou), kind: Notification.kinds[:first_report])
    assert_not(notifications.any? { |n| n.message.include?(notification_message) })

    notifications = Notification.where(user: users(:sotugyou), kind: Notification.kinds[:first_report])
    assert_not(notifications.any? { |n| n.message.include?(notification_message) })
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

    notifications = Notification.where(user: users(:komagata), kind: Notification.kinds[:first_report])
    assert_not(notifications.any? { |n| n.message.include?('kensyuさんがはじめての日報を書きました！') })

    visit_with_auth "/users/#{users(:kensyu).id}/reports", 'kensyu'
    click_link 'test title'
    click_link '内容修正'
    click_button '提出'
    assert_text '日報を保存しました。'

    notifications = Notification.where(user: users(:komagata), kind: Notification.kinds[:first_report])
    assert(notifications.any? { |n| n.message.include?('kensyuさんがはじめての日報を書きました！') })
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

    notifications = Notification.where(user: users(:komagata), kind: Notification.kinds[:first_report])
    assert_not(notifications.any? { |n| n.message.include?('kensyuさんがはじめての日報を書きました！') })
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

    notifications = Notification.where(user: users(:komagata), kind: Notification.kinds[:first_report])
    assert_not(notifications.any? { |n| n.message.include?('kimuraさんがはじめての日報を書きました！') })
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

  test 'notify company advisor only when report is initially posted' do
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

  test 'notify follower only when report is initially posted' do
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

  test 'notify mention target only when report is initially posted' do
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

  test 'notify user only when first report is initially posted' do
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

  test 'notify to mentors when a student submitted reports with negative icon at twice in a row' do
    student = 'kimura'
    mentor = 'mentormentaro'

    visit_with_auth '/reports', student

    click_link '日報作成'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title 1')
      fill_in('report[description]', with: 'test 1')
      fill_in('report[reported_on]', with: Date.current.prev_day)
      find('#negative').click
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
      find('#negative').click
    end
    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')
    click_button '提出'
    find('.modal-header__close').click

    visit_with_auth '/notifications', mentor

    within first('.card-list-item.is-unread') do
      assert_text "#{student}さんが2回連続でnegativeアイコンの日報を提出しました。"
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

    # コードブロック内のメンションは通知されない
    notifications = Notification.where(user: users(:komagata), kind: Notification.kinds[:mentioned], read: false)
    assert_not(notifications.any? { |n| n.sender == users(:kimura) })
  end
end
