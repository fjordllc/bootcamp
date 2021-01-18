# frozen_string_literal: true

require 'application_system_test_case'

class NotificationsTest < ApplicationSystemTestCase
  test 'do not send mail if user deny mail' do
    login_user 'kimura', 'testtest'
    visit "/reports/#{reports(:report8).id}"
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    click_button 'コメントする'
    wait_for_vuejs

    if ActionMailer::Base.deliveries.present?
      last_mail = ActionMailer::Base.deliveries.last
      assert_not_equal '[Bootcamp] kimuraさんからコメントが届きました。', last_mail.subject
    end
  end

  test "don't notify the same report" do
    login_user 'komagata', 'testtest'
    visit '/notifications'
    click_link '全て既読にする'

    login_user 'kensyu', 'testtest'
    visit '/reports/new'
    fill_in 'report_title', with: 'テスト日報'
    fill_in 'report_description', with: 'none'
    select '23', from: :report_learning_times_attributes_0_started_at_4i
    select '00', from: :report_learning_times_attributes_0_started_at_5i
    select '00', from: :report_learning_times_attributes_0_finished_at_4i
    select '00', from: :report_learning_times_attributes_0_finished_at_5i
    click_button '提出'

    find('#js-new-comment').set("login_nameの補完テスト: @komagata\n")
    click_button 'コメントする'
    wait_for_vuejs
    assert_text 'login_nameの補完テスト: @komagata'
    assert_selector :css, "a[href='/users/komagata']"

    login_user 'komagata', 'testtest'
    visit '/notifications'
    wait_for_vuejs
    assert_no_text 'kensyuさんがはじめての日報を書きました！'
    assert_text 'kensyuさんからメンションがきました。'
  end

  test 'do not show read notification on the unread notifications' do
    Notification.create(message: '1番新しい既読の通知', read: true,
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned', path: '/reports/20400118',
                        user: users(:yamada), sender: users(:machida))
    login_user 'yamada', 'testtest'
    visit '/notifications/unread'
    wait_for_vuejs
    assert_no_text '1番新しい既読の通知'
  end

  test 'click on the pager button' do
    30.times do |n|
      Notification.create(message: "machidaさんからメンションが届きました#{n}",
                          kind: 'mentioned', path: "/reports/#{n}",
                          user: users(:yamada), sender: users(:machida))
    end
    Notification.create(message: '1番新しい通知', created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned', path: '/reports/20400118',
                        user: users(:yamada), sender: users(:machida))
    Notification.create(message: '1番古い通知', created_at: '2000-01-18 06:06:42',
                        kind: 'mentioned', path: '/reports/20000118',
                        user: users(:yamada), sender: users(:machida))
    login_user 'yamada', 'testtest'
    visit '/notifications'
    wait_for_vuejs
    within first('div.pagination') do
      find('a', text: '2').click
    end
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_current_path('/notifications?page=2')
  end

  test 'specify the page number in the URL' do
    30.times do |n|
      Notification.create(message: "machidaさんからメンションが届きました#{n}",
                          kind: 'mentioned', path: "/reports/#{n}",
                          user: users(:yamada), sender: users(:machida))
    end
    Notification.create(message: '1番新しい通知', created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned', path: '/reports/20400118',
                        user: users(:yamada), sender: users(:machida))
    Notification.create(message: '1番古い通知', created_at: '2000-01-18 06:06:42',
                        kind: 'mentioned', path: '/reports/20000118',
                        user: users(:yamada), sender: users(:machida))
    login_user 'yamada', 'testtest'
    visit '/notifications?page=2'
    wait_for_vuejs
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
  end

  test 'clicking the browser back button will show the previous page' do
    30.times do |n|
      Notification.create(message: "machidaさんからメンションが届きました#{n}",
                          kind: 'mentioned', path: "/reports/#{n}",
                          user: users(:yamada), sender: users(:machida))
    end
    Notification.create(message: '1番新しい通知', created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned', path: '/reports/20400118',
                        user: users(:yamada), sender: users(:machida))
    Notification.create(message: '1番古い通知', created_at: '2000-01-18 06:06:42',
                        kind: 'mentioned', path: '/reports/20000118',
                        user: users(:yamada), sender: users(:machida))
    login_user 'yamada', 'testtest'
    visit '/notifications?page=2'
    wait_for_vuejs
    within first('div.pagination') do
      find('a', text: '1').click
    end
    page.go_back
    wait_for_vuejs
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
  end
end
