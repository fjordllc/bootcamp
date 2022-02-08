# frozen_string_literal: true

module NotificationHelper
  def ensure_notifications?(target)
    current_user.notifications.by_target(target).unreads.latest_of_each_link.size.positive?
  end
end
