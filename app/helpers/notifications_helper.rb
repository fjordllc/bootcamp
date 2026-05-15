# frozen_string_literal: true

module NotificationsHelper
  def ensure_notifications?(target)
    current_user.notifications.by_target(target).unreads.latest_of_each_link.size.positive?
  end

  def notification_count(target)
    key = target == :all ? nil : target
    current_user.notifications.by_target(key).unreads.latest_of_each_link.size
  end
end
