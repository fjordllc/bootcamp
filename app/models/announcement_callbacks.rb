# frozen_string_literal: true

class AnnouncementCallbacks
  def after_create(announce)
    return if announce.wip?

    after_first_publish(announce)
    create_author_watch(announce)
  end

  def after_update(announce)
    return unless !announce.wip && announce.published_at.nil?

    after_first_publish(announce)
  end

  private

  def after_first_publish(announce)
    send_notification(announce)
    announce.update(published_at: Time.current)
  end

  def send_notification(announce)
    target_users = User.announcement_receiver(announce.target)
    target_users.each_with_index do |target, index|
      first_call = true if index.zero?
      NotificationFacade.post_announcement(announce, target, first_call) if announce.sender != target
    end
  end

  def delete_notification(announce)
    Notification.where(link: "/announcements/#{announce.id}").destroy_all
  end

  def create_author_watch(announce)
    Watch.create!(user: announce.user, watchable: announce)
  end
end
