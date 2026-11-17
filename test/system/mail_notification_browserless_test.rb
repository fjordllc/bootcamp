# frozen_string_literal: true

require 'browserless_system_test_case'

class MailNotificationsBrowserlessTest < BrowserlessSystemTestCase
  test "can not update other user's mail_notification" do
    visit "/users/#{users(:komagata).id}/mail_notification/edit?token=#{users(:kimura).unsubscribe_email_token}"
    assert_text 'ユーザーIDもしくはTOKENが違います。'
  end
end
