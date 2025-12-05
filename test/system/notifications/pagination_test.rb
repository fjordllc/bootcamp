# frozen_string_literal: true

require 'application_system_test_case'

class Notifications::PaginationTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'click on the pager button' do
    # 1ページに表示する通知の数は20件なのでtimesメソッドを使って19件作成し、一番新しい通知、古い通知を個別に作成する
    19.times do |n|
      Notification.create(message: "machidaさんからメンションが届きました#{n}",
                          kind: 'mentioned',
                          link: "/reports/#{n}",
                          user: users(:mentormentaro),
                          sender: users(:machida))
    end
    Notification.create(message: '1番新しい通知',
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    Notification.create(message: '1番古い通知',
                        created_at: '2000-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20000118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    login_user 'mentormentaro', 'testtest'
    visit '/notifications'
    within first('nav.pagination') do
      find('button', text: '2').click
    end
    # 2ページ目に1番古い通知が表示されることを確認
    assert_text '1番古い通知'
    # 2ページ目に1番新しい通知が表示されないことを確認
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_current_path('/notifications?page=2')
  end

  test 'show 20 notifications in first page' do
    25.times do |n|
      Notification.create(message: "machidaさんからメンションが届きました#{n}",
                          kind: 'mentioned',
                          link: "/reports/#{n}",
                          user: users(:mentormentaro),
                          sender: users(:machida))
    end
    Notification.create(message: '1番新しい通知',
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    login_user 'mentormentaro', 'testtest'
    visit '/notifications'
    assert_text '1番新しい通知'
    assert_equal 20, all('.card-list-item').size

    visit '/notifications?status=unread'
    assert_text '1番新しい通知'
    assert_equal 20, all('.card-list-item').size
  end

  test 'click on the pager button with query string' do
    19.times do |n|
      Notification.create(message: "machidaさんからメンションが届きました#{n}",
                          kind: 'mentioned',
                          link: "/reports/#{n}",
                          user: users(:mentormentaro),
                          sender: users(:machida))
    end
    Notification.create(message: '1番新しい通知',
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    Notification.create(message: '1番古い通知',
                        created_at: '2000-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20000118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    login_user 'mentormentaro', 'testtest'
    visit '/notifications?status=unread'
    within first('nav.pagination') do
      find('button', text: '2').click
    end
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_current_path('/notifications?status=unread&page=2')
  end

  test 'click on the pager button with multiple query string' do
    19.times do |n|
      Notification.create(message: "machidaさんからメンションが届きました#{n}",
                          kind: 'mentioned',
                          link: "/reports/#{n}",
                          user: users(:mentormentaro),
                          sender: users(:machida))
    end
    Notification.create(message: '1番新しい通知',
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    Notification.create(message: '1番古い通知',
                        created_at: '2000-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20000118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    login_user 'mentormentaro', 'testtest'
    visit '/notifications?status=unread&target=mention'
    within first('nav.pagination') do
      find('button', text: '2').click
    end
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_current_path('/notifications?status=unread&target=mention&page=2')
  end

  test 'specify the page number in the URL' do
    19.times do |n|
      Notification.create(message: "machidaさんからメンションが届きました#{n}",
                          kind: 'mentioned',
                          link: "/reports/#{n}",
                          user: users(:mentormentaro),
                          sender: users(:machida))
    end
    Notification.create(message: '1番新しい通知',
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    Notification.create(message: '1番古い通知',
                        created_at: '2000-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20000118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    login_user 'mentormentaro', 'testtest'
    visit '/notifications?page=2'
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
  end

  test 'clicking the browser back button will show the previous page' do
    19.times do |n|
      Notification.create(message: "machidaさんからメンションが届きました#{n}",
                          kind: 'mentioned',
                          link: "/reports/#{n}",
                          user: users(:mentormentaro),
                          sender: users(:machida))
    end
    Notification.create(message: '1番新しい通知',
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    Notification.create(message: '1番古い通知',
                        created_at: '2000-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20000118',
                        user: users(:mentormentaro),
                        sender: users(:machida))
    login_user 'mentormentaro', 'testtest'
    visit '/notifications?page=2'
    within first('nav.pagination') do
      find('button', text: '1').click
    end
    assert_text '1番新しい通知'
    page.go_back
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
  end
end
