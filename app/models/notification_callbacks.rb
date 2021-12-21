# frozen_string_literal: true

class NotificationCallbacks
  def after_create(notification)
    return if notification.kind != 'watching'

    Cache.delete_notification_all_count(notification.user.id)
    Cache.delete_notification_unread_count(notification.user.id)
  end

  def after_update(notification)
    return if notification.kind != 'watching'

    Cache.delete_notification_unread_count(notification.user.id)
  end
end
