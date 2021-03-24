# frozen_string_literal: true

require 'application_system_test_case'

class Notification::ReportsTest < ApplicationSystemTestCase
  test 'はじめての日報が投稿されたときに全員が通知を受け取る' do
    login_user 'muryou', 'testtest'
    visit '/reports'
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
    assert_equal 'muryouさんがはじめての日報を書きました！',
                 notification_message
    logout

    login_user 'yamada', 'testtest'
    open_notification
    assert_equal 'muryouさんがはじめての日報を書きました！',
                 notification_message
    logout
  end

  test '複数の日報が投稿されているときは通知が飛ばない' do
    # 他のテストの通知に影響を受けないよう、テスト実行前に通知を削除する
    login_user 'muryou', 'testtest'
    visit '/notifications'
    click_link '全て既読にする'

    login_user 'komagata', 'testtest'
    visit '/reports'
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
    notify_message, author_login_name, recived_user_login_name, title, description
  )
    exists_notify_in_unread = -> { exists_unread_notify?(notify_message) }
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
        assert exists_notify_in_unread.call
        link_to_page_by_unread_notify(notify_message)
        assert_equal current_path, report_path(report_id)
      else
        assert_not exists_notify_in_unread.call
      end
      logout
    end
  end

  test '研修生が初めて提出した時だけ、企業のアドバイザーに通知する' do
    kensyu_login_name = 'kensyu'
    advisor_login_name = 'senpai'
    title = '研修生が初めて提出した時だけ、'
    description = 'アドバイザーに通知を飛ばす'
    notify_message = make_write_report_notify_message(
      kensyu_login_name, title
    )
    assert_notify_only_at_first_published_of_report(
      notify_message,
      kensyu_login_name,
      advisor_login_name,
      title,
      description
    )
  end
end
