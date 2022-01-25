# frozen_string_literal: true

class NotificationCallbacks
  def after_create(notification)
    return unless notification.mentioned? && notification.unique?(scope: %i[link user_id kind])

    Cache.delete_mentioned_notification_count(notification.user.id)

    return unless notification.unread? && notification.unique?(scope: %i[link user_id kind read])

    Cache.delete_mentioned_and_unread_notification_count(notification.user.id)
  end

  def after_update(notification)
    return unless notification.mentioned? && notification.saved_change_to_attribute?('read', from: false, to: true)

    notification.assign_attributes(read: false)

    return unless notification.unique?(scope: %i[link user_id kind read])

    Cache.delete_mentioned_and_unread_notification_count(notification.user.id)
  end

  def after_destroy(notification)
    return unless notification.mentioned? && notification.unique?(scope: %i[link user_id kind])

    Cache.delete_mentioned_notification_count(notification.user.id)

    return unless notification.unread? && notification.unique?(scope: %i[link user_id kind read])

    Cache.delete_mentioned_and_unread_notification_count(notification.user.id)
  end
end
