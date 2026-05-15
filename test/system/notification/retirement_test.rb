# frozen_string_literal: true

require 'notification_system_test_case'

class Notification::RetirementTest < NotificationSystemTestCase
  test 'notify admins and mentors when a user retire' do
    assert_user_has_no_notification(user: users(:komagata), kind: Notification.kinds[:retired], text: 'kimuraさんが退会しました。')

    visit_with_auth new_retirement_path, 'kimura'
    find('label', text: 'とても良い').click
    click_on '退会する'
    page.driver.browser.switch_to.alert.accept
    assert_text '退会処理が完了しました'

    assert_user_has_notification(user: users(:komagata), kind: Notification.kinds[:retired], text: 'kimuraさんが退会しました。')
  end
end
