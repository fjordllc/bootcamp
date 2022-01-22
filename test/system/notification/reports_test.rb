# frozen_string_literal: true

require 'application_system_test_case'

class Notification::ReportsTest < ApplicationSystemTestCase
  test 'はじめての日報が投稿されたときにメンターと現役生が通知を受け取る' do
    visit_with_auth '/reports', 'muryou'
    click_link '日報作成'

    within('#new_report') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
    end

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')

    click_button '提出'
    logout

    login_user 'komagata', 'testtest'
    open_notification
    assert_equal 'muryouさんがはじめての日報を書きました！', notification_message
    logout

    login_user 'kimura', 'testtest'
    open_notification
    assert_equal 'muryouさんがはじめての日報を書きました！', notification_message
    logout
  end

  test 'はじめての日報が投稿されたときにアドバイザーと卒業生は通知を受け取らない' do
    # 他のテストの通知に影響を受けないよう、テスト実行前に通知を削除する
    visit_with_auth '/notifications', 'advijirou'
    click_link '全て既読にする'

    visit_with_auth '/notifications', 'sotugyou'
    click_link '全て既読にする'

    visit_with_auth '/reports', 'muryou'
    click_link '日報作成'

    within('#new_report') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
    end

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')

    click_button '提出'
    logout

    login_user 'advijirou', 'testtest'
    # sleepメソッドで一定時間停止しないと、cssが読み込まれる前に”assert page.has_css?('.has-no-count')”を実行してしまう。
    sleep 1
    assert page.has_css?('.has-no-count')

    login_user 'sotugyou', 'testtest'
    sleep 1
    assert page.has_css?('.has-no-count')
  end

  test '複数の日報が投稿されているときは通知が飛ばない' do
    # 他のテストの通知に影響を受けないよう、テスト実行前に通知を削除する
    visit_with_auth '/notifications', 'muryou'
    click_link '全て既読にする'

    visit_with_auth '/reports', 'komagata'
    click_link '日報作成'

    within('#new_report') do
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

  test '研修生が初めて提出した時だけ、企業のアドバイザーに通知する' do
    kensyu_login_name = 'kensyu'
    advisor_login_name = 'senpai'
    title = '研修生が初めて提出した時だけ、'
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
    check_notification_login_name = 'kimura'
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
    mentor = 'yamada'

    visit_with_auth '/reports', student

    click_link '日報作成'
    within('#new_report') do
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

    click_link '日報作成'
    within('#new_report') do
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

    logout

    login_user mentor, 'testtest'
    open_notification

    assert_equal "#{student}さんが2回連続でsadアイコンの日報を提出しました。", notification_message
  end
end
