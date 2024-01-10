# frozen_string_literal: true

class AnnouncementNotificationDestroyer
  def call(payload)
    announcement = payload[:announcement]
    Notification.where(link: "/announcements/#{announcement.id}").destroy_all
  end
end
