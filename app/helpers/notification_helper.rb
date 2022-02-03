module NotificationHelper
  def ensure_notifications?
    current_user.notifications.by_target(@target).unreads.latest_of_each_link.size.positive?
  end
end
