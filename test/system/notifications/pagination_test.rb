# frozen_string_literal: true

require 'application_system_test_case'

class Notifications::PaginationTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    @user = users(:mentormentaro)
    @sender = users(:machida)
    @user.notifications.destroy_all
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'click on the pager button' do
    create_pagination_notifications(19)
    create_boundary_notifications

    login_user 'mentormentaro', 'testtest'
    visit '/notifications'
    within first('nav.pagination') do
      click_link_or_button '2'
    end
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_current_path('/notifications?page=2')
  end

  test 'show 20 notifications in first page' do
    create_pagination_notifications(25)
    create_newest_notification

    login_user 'mentormentaro', 'testtest'
    visit '/notifications'
    assert_text '1番新しい通知'
    assert_equal 20, all('.card-list-item').size

    visit '/notifications?status=unread'
    assert_text '1番新しい通知'
    assert_equal 20, all('.card-list-item').size
  end

  test 'click on the pager button with query string' do
    create_pagination_notifications(19)
    create_boundary_notifications

    login_user 'mentormentaro', 'testtest'
    visit '/notifications?status=unread'
    within first('nav.pagination') do
      click_link_or_button '2'
    end
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_match %r{/notifications\?(status=unread&page=2|page=2&status=unread)}, current_url
  end

  test 'click on the pager button with multiple query string' do
    create_pagination_notifications(19)
    create_boundary_notifications

    login_user 'mentormentaro', 'testtest'
    visit '/notifications?status=unread&target=mention'
    within first('nav.pagination') do
      click_link_or_button '2'
    end
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_match %r{/notifications\?(status=unread&page=2|page=2&status=unread)}, current_url
  end

  test 'specify the page number in the URL' do
    create_pagination_notifications(19)
    create_boundary_notifications

    login_user 'mentormentaro', 'testtest'
    visit '/notifications?page=2'
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
  end

  test 'clicking the browser back button will show the previous page' do
    create_pagination_notifications(19)
    create_boundary_notifications

    login_user 'mentormentaro', 'testtest'
    visit '/notifications?page=2'
    within first('nav.pagination') do
      click_link_or_button '1'
    end
    assert_text '1番新しい通知'
    page.go_back
    assert_text '1番古い通知'
    assert_no_text '1番新しい通知'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
  end

  private

  def create_pagination_notifications(count)
    now = Time.current
    notifications = Array.new(count) do |n|
      {
        message: "machidaさんからメンションが届きました#{n}",
        kind: 'mentioned',
        link: "/reports/#{n}",
        user_id: @user.id,
        sender_id: @sender.id,
        created_at: now,
        updated_at: now
      }
    end
    Notification.insert_all(notifications) # rubocop:disable Rails/SkipsModelValidations
  end

  def create_boundary_notifications
    create_newest_notification
    create_oldest_notification
  end

  def create_newest_notification
    Notification.create(message: '1番新しい通知',
                        created_at: '2040-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20400118',
                        user: @user,
                        sender: @sender)
  end

  def create_oldest_notification
    Notification.create(message: '1番古い通知',
                        created_at: '2000-01-18 06:06:42',
                        kind: 'mentioned',
                        link: '/reports/20000118',
                        user: @user,
                        sender: @sender)
  end
end
