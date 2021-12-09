# frozen_string_literal: true

class NotificationCallbacks
  def after_create(notification)
    return unless notification.mentioned?

    Cache.delete_mentioned_notification_count(notification.user.id)
    Cache.delete_mentioned_and_unread_notification_count(notification.user.id)
  end

  def after_update(notification)
    return unless notification.mentioned? && notification.saved_change_to_attribute?('read')

    Cache.delete_mentioned_and_unread_notification_count(notification.user.id)
  end

  def after_destroy(notification)
    return unless notification.mentioned?

    Cache.delete_mentioned_notification_count(notification.user.id)
    Cache.delete_mentioned_and_unread_notification_count(notification.user.id) if notification.unread?
  end
end
