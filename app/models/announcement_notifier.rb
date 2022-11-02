# frozen_string_literal: true

class AnnouncementNotifier
  def call(announce)
    return if announce.wip? || announce.published_at.present?

    announce.update(published_at: Time.current)
    DiscordNotifier.with(announce: announce).announced.notify_now
    Watch.create!(user: announce.user, watchable: announce)

    target_users = User.announcement_receiver(announce.target)
    target_users.each do |target|
      next if announce.sender == target

      NotificationFacade.post_announcement(announce, target)
    end
  end
end
