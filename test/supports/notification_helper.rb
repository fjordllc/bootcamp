# frozen_string_literal: true

module NotificationHelper
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
    wait_for_vuejs # 通知一覧はVueでREST APIを利用して表示しているため
    exists = page.has_selector?('span.thread-list-item-title__link-label',
                                text: message)
    go_back
    exists
  end

  def link_to_page_by_unread_notification(message)
    visit notifications_path(status: 'unread')
    wait_for_vuejs # 通知一覧はVueでREST APIを利用して表示しているため
    click_link message, class: 'thread-list-item-title__link'
  end

  def make_write_report_notification_message(user_login_name, report_title)
    "#{user_login_name}さんが日報【 #{report_title} 】を書きました！"
  end

  def make_mention_notification_message(writer_login_name)
    "#{writer_login_name}さんからメンションがきました。"
  end
end
