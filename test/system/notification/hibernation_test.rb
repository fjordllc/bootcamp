# frozen_string_literal: true

require 'notification_system_test_case'

class Notification::HibernationTest < NotificationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'notify admins and mentors when a student hibernate' do
    assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:hibernated], text: 'kimuraさんが休会しました。')

    visit_with_auth new_hibernation_path, 'kimura'
    fill_in 'hibernation[scheduled_return_on]', with: Time.current.next_month
    fill_in 'hibernation[reason]', with: 'テストのため'
    find('.check-box-to-read').click
    accept_confirm do
      click_button '休会する'
    end
    assert_text '休会手続きが完了しました'

    assert_user_has_notification(user: users(:komagata), kind: Notification.kinds[:hibernated], text: 'kimuraさんが休会しました。')
  end

  test 'notify admins and mentors when a trainee hibernate' do
    assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:hibernated], text: 'kensyuさんが休会しました。')

    visit_with_auth new_hibernation_path, 'kensyu'
    fill_in 'hibernation[scheduled_return_on]', with: Time.current.next_month
    fill_in 'hibernation[reason]', with: 'テストのため'
    find('.check-box-to-read').click
    accept_confirm do
      click_button '休会する'
    end
    assert_text '休会手続きが完了しました'

    assert_user_has_notification(user: users(:komagata), kind: Notification.kinds[:hibernated], text: 'kensyuさんが休会しました。')
  end

  test 'notify admins and mentors when a adviser hibernate' do
    assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:hibernated], text: 'senpaiさんが休会しました。')

    visit_with_auth new_hibernation_path, 'senpai'
    fill_in 'hibernation[scheduled_return_on]', with: Time.current.next_month
    fill_in 'hibernation[reason]', with: 'テストのため'
    find('.check-box-to-read').click
    accept_confirm do
      click_button '休会する'
    end
    assert_text '休会手続きが完了しました'

    assert_user_has_notification(user: users(:komagata), kind: Notification.kinds[:hibernated], text: 'senpaiさんが休会しました。')
  end
end
