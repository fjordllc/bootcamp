# frozen_string_literal: true

class AnnouncementNotifier
  def call(announce)
    return if announce.wip? || announce.published_at?

    announce.update(published_at: Time.current)
    DiscordNotifier.with(announce:).announced.notify_now
    Watch.create!(user: announce.user, watchable: announce)

    target_users = User.announcement_receiver(announce.target)
    target_users.each do |target|
      next if announce.sender == target

      ActivityDelivery.with(announcement: announce, receiver: target).notify(:post_announcement)
    end
  end
end
