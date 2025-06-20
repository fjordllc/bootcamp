# frozen_string_literal: true

require 'application_system_test_case'

class MailNotificationsTest < ApplicationSystemTestCase
  test "update user's mail_notification" do
    visit "/users/#{users(:kimura).id}/mail_notification/edit?token=#{users(:kimura).unsubscribe_email_token}"

    # Wait for the correct page to be loaded by checking the <title>
    assert page.has_title?('メール通知解除の確認')

    # Wait for page body to load first
    assert_selector '.page-body'

    # Wait for unauthorized section to appear with more specific targeting
    assert_selector 'article.unauthorized'
    assert_text 'メール通知をオフにしますか？'

    # Ensure the actions section is loaded before interacting
    assert_selector '.unauthorized-actions'
    assert_selector '.unauthorized-actions a', text: 'オフにする'

    within '.unauthorized-actions' do
      click_link 'オフにする'
    end

    assert_text 'メール配信を停止しました。'
  end

  test "can not update other user's mail_notification" do
    visit "/users/#{users(:komagata).id}/mail_notification/edit?token=#{users(:kimura).unsubscribe_email_token}"
    assert_text 'ユーザーIDもしくはTOKENが違います。'
  end
end
