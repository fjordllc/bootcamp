# frozen_string_literal: true

class AnnouncementCallbacks
  def after_create(announce)
    return if announce.wip?

    send_notification(announce)
    announce.published_at = Time.current
    announce.save
  end

  def after_update(announce)
    return unless !announce.wip && announce.published_at.nil?

    send_notification(announce)
    announce.published_at = Time.current
    announce.save
  end

  def after_destroy(announce)
    delete_notification(announce)
  end

  private

  def send_notification(announce)
    target_users = User.announcement_receiver(announce.target)
    target_users.each do |target|
      NotificationFacade.post_announcement(announce, target) if announce.sender != target
    end
  end

  def delete_notification(announce)
    Notification.where(path: "/announcements/#{announce.id}").destroy_all
  end
end
