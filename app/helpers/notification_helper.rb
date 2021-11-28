# frozen_string_literal: true

module NotificationHelper
  def read_batche(current_user, target)
    return Cache.read_announcement_count(current_user.id) if target == 'announcement'
  end

  def unread_batche(current_user, target)
    return Cache.unread_announcement_count(current_user.id) if target == 'announcement'
  end
end
