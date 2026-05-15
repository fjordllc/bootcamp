# frozen_string_literal: true

module NotificationHelper
  def notifications(user:, target:, status:)
    UserNotificationsQuery.new(user:, target:, status:).call
  end

  def notification_message
    first('.test-notification-message').text
  end

  def notification_messages
    all('.test-notification-message').map(&:text)
  end

  # notification_messages.include?(text)
  # でも可能だが、notification_messagesは
  # open_notificationを実行した(右上のベルボタンを押した)かで
  # 戻り値が変更されるため、これを作成
  def exists_unread_notification?(message)
    visit notifications_path(status: 'unread')
    wait_for_notifications_loaded
    exists = page.has_selector?('span.card-list-item-title__link-label',
                                text: message)
    go_back
    exists
  end

  def link_to_page_by_unread_notification(message)
    visit notifications_path(status: 'unread')
    wait_for_notifications_loaded
    click_link message, class: 'card-list-item-title__link'
  end

  def user_has_notification?(user:, kind:, text: nil, unread: false, sender: nil)
    notifications = Notification.where(user:, kind:)
    notifications = notifications.unreads if unread
    notifications = notifications.where(sender:) if sender
    return notifications.any? unless text

    notifications.any? { |n| n.message.include?(text) }
  end

  def assert_user_has_notification(user:, kind:, text: nil, unread: false, sender: nil)
    assert user_has_notification?(user:, kind:, text:, unread:, sender:),
           "#{user.login_name} should have notification with text: #{text}"
  end

  def assert_user_has_no_notification(user:, kind:, text: nil, unread: false, sender: nil)
    assert_not user_has_notification?(user:, kind:, text:, unread:, sender:),
               "#{user.login_name} should not have notification with text: #{text}"
  end

  private

  def wait_for_notifications_loaded
    using_wait_time 20 do
      assert_no_selector '#notifications.loading'
    end
  end

  def make_write_report_notification_message(user_login_name, report_title)
    "#{user_login_name}さんが日報【 #{report_title} 】を書きました！"
  end

  def make_mention_notification_message(writer_login_name)
    "#{writer_login_name}さんからメンションがきました。"
  end

  def notification_message_for_mention(owner_login_name, comment_user_login_name)
    "#{owner_login_name}さんの分報で#{comment_user_login_name}さんからメンションがきました。"
  end

  def first_report_message(login_name)
    "#{login_name}さんがはじめての日報を書きました！"
  end
end
