# frozen_string_literal: true

require 'application_system_test_case'

class MailNotificationsTest < ApplicationSystemTestCase
  test "update user's mail_notification settings while logged in" do
    url = "/users/#{users(:kimura).id}/mail_notification/edit?token=#{users(:kimura).unsubscribe_email_token}"
    visit_with_auth url, 'kimura'
    assert_text 'メール通知をオフにしますか？'
    click_on 'オフにする'
    assert_text 'メール配信を停止しました。'
  end

  test "update user's mail_notification settings without being logged in" do
    visit "/users/#{users(:kimura).id}/mail_notification/edit?token=#{users(:kimura).unsubscribe_email_token}"
    assert_text 'ログインしてください'
  end

  test "update another user's mail_notification" do
    url = "/users/#{users(:kimura).id}/mail_notification/edit?token=#{users(:kimura).unsubscribe_email_token}"
    visit_with_auth url, 'komagata'
    assert_text 'メール通知をオフにしますか？'
    click_on 'オフにする'
    assert_text '無効な操作です。'
  end
end
