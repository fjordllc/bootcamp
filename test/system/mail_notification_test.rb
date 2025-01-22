# frozen_string_literal: true

require 'application_system_test_case'

class MailNotificationsTest < ApplicationSystemTestCase
  test "update user's mail_notification" do
    visit "/users/#{users(:kimura).id}/mail_notification/edit?token=#{users(:kimura).unsubscribe_email_token}"
    assert_text 'メール通知をオフにしますか？'
    click_on 'オフにする'
    assert_text 'メール配信を停止しました。'
  end

  test "can not update other user's mail_notification" do
    visit "/users/#{users(:komagata).id}/mail_notification/edit?token=#{users(:kimura).unsubscribe_email_token}"
    assert_text 'ユーザーIDもしくはTOKENが違います。'
  end
end
