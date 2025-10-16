# frozen_string_literal: true

require 'application_system_test_case'

class MailNotificationsTest < ApplicationSystemTestCase
  test "update user's mail_notification" do
    visit "/users/#{users(:kimura).id}/mail_notification/edit?token=#{users(:kimura).unsubscribe_email_token}"

    refute_text 'ユーザーIDもしくはTOKENが違います。'
    assert_selector 'article.unauthorized'
    assert_text 'メール通知をオフにしますか？'
    assert_title 'メール通知解除の確認'
    assert_selector '.unauthorized-actions a', text: 'オフにする'

    click_link 'オフにする'

    assert_text 'メール配信を停止しました。'
  end

  test "can not update other user's mail_notification" do
    visit "/users/#{users(:komagata).id}/mail_notification/edit?token=#{users(:kimura).unsubscribe_email_token}"
    assert_text 'ユーザーIDもしくはTOKENが違います。'
  end
end
