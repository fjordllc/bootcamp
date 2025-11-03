# frozen_string_literal: true

require 'notification_system_test_case'

class Notification::RetirementTest < NotificationSystemTestCase
  test 'notify admins and mentors when a user retire' do
    notifications = Notification.where(user: users(:komagata), kind: Notification.kinds[:retired])
    assert_not(notifications.any? { |n| n.message.include?('kimuraさんが退会しました。') })

    visit_with_auth new_retirement_path, 'kimura'
    find('label', text: 'とても良い').click
    click_on '退会する'
    page.driver.browser.switch_to.alert.accept
    assert_text '退会処理が完了しました'

    notifications = Notification.where(user: users(:komagata), kind: Notification.kinds[:retired])
    assert(notifications.any? { |n| n.message.include?('kimuraさんが退会しました。') })
  end
end
