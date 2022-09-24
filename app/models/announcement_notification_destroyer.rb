# frozen_string_literal: true

class AnnouncementNotificationDestroyer
  def call(announce)
    Notification.where(link: "/announcements/#{announce.id}").destroy_all
  end
end
