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

  test '研修生が日報を提出したら企業のアドバイザーに通知が飛ぶ' do
    login_user 'kensyu', 'testtest'
    visit '/reports/new'
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

    login_user 'senpai', 'testtest'
    open_notification
    assert_equal 'kensyuさんが日報【 test title 】を書きました！',
                 notification_message
  end

  test '初日報は初めて公開した時だけ通知する' do
    author_name = 'muryou'
    login_user author_name, 'testtest'
    visit '/reports'
    click_link '日報作成'
    first_report_title = 'test title'
    first_repor_description = 'test'
    within('#new_report') do
      fill_in('report[title]', with: first_report_title)
      fill_in('report[description]', with: first_repor_description)
    end

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')

    click_button '提出'
    logout

    receiver_user = 'yamada'
    login_user receiver_user, 'testtest'
    open_notification
    
    message = "#{author_name}さんがはじめての日報を書きました！"
    assert_equal message, notification_message
    click_link '全て既読にする'
    logout

    login_user author_name, 'testtest'
    visit '/reports'

    click_link first_report_title
    click_link '内容修正'

    fill_in('report[description]', with: 'testtest')
    click_button '内容変更'
    logout

    login_user receiver_user, 'testtest'
    click_link '通知'
    assert_no_text message
    logout
  end
end
