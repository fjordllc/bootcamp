# frozen_string_literal: true

module NotificationHelper
  def open_notification
    sleep 1
    first('.test-bell').click
  end

  def notification_message
    first('.test-notification-message').text
  end

  def notification_messages
    all('.test-notification-message').map(&:text)
  end
end
