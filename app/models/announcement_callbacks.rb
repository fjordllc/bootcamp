# frozen_string_literal: true

class AnnouncementCallbacks
  def after_create(announce)
    send_notification(announce)
  end

  def after_destroy(announce)
    delete_notification(announce)
  end

  private
    def send_notification(announce)
      target_users = User.announcement(announce.target)
      target_users.each do |target|
        if announce.sender != target
          NotificationFacade.post_announcement(announce, target)
        end
      end
    end

    def delete_notification(announce)
      Notification.where(path: "/announcements/#{announce.id}").destroy_all
    end
end
