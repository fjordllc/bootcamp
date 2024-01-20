# frozen_string_literal: true

class AnnouncementNotificationDestroyer
  def call(payload)
    announce = payload[:announcement]
    Notification.where(link: "/announcements/#{announce.id}").destroy_all
  end
end
