# frozen_string_literal: true

class AnnouncementNotifier
  def call(announce)
    return if announce.wip? || !announce.published_at.nil?

    announce.update(published_at: Time.current)
    DiscordNotifier.with(announce: announce).announced.notify_now

    target_users = User.announcement_receiver(announce.target)
    target_users.each do |target|
      NotificationFacade.post_announcement(announce, target) if announce.sender != target
    end
  end
end
