# frozen_string_literal: true

class AnnouncementNotifier
  def call(payload)
    announcement = payload[:announcement]
    return if announcement.wip? || announcement.published_at?

    announcement.update(published_at: Time.current)
    DiscordNotifier.with(announce: announcement).announced.notify_now
    Watch.create!(user: announcement.user, watchable: announcement)

    receivers = User.announcement_receiver(announcement.target).reject { |receiver| receiver == announcement.sender }
    PostAnnouncementJob.perform_later(announcement, receivers)
  end
end
