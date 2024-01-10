# frozen_string_literal: true

class AnnouncementNotifier
  def call(payload)
    announcement = payload[:announcement]
    return if announcement.wip? || announcement.published_at?

    announcement.update(published_at: Time.current)
    DiscordNotifier.with(announce: announcement).announced.notify_now
    Watch.create!(user: announcement.user, watchable: announcement)

    target_users = User.announcement_receiver(announcement.target)
    target_users.each do |target|
      next if announcement.sender == target

      ActivityDelivery.with(announcement: announcement, receiver: target).notify(:post_announcement)
    end
  end
end
