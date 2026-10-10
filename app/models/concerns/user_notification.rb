# frozen_string_literal: true

# ユーザーの通知(送受信・既読管理)に関する責務をまとめたもの。
module UserNotification
  extend ActiveSupport::Concern

  included do
    has_many :notifications, dependent: :destroy
    has_many :send_notifications,
             class_name: 'Notification',
             foreign_key: 'sender_id',
             inverse_of: 'sender',
             dependent: :destroy

    validates :mail_notification, inclusion: { in: [true, false] }
  end

  def mark_all_as_read_and_delete_cache_of_unreads(target_notifications: nil)
    target_notifications ||= notifications
    target_notifications.update_all(read: true, updated_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
    Cache.delete_mentioned_and_unread_notification_count(id)
  end
end
