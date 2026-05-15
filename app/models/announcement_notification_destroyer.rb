# frozen_string_literal: true

class AnnouncementNotificationDestroyer
  def call(_name, _started, _finished, _unique_id, payload)
    announcement = payload[:announcement]
    Notification.where(link: "/announcements/#{announcement.id}").destroy_all
  end
end
