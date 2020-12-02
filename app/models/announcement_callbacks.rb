# frozen_string_literal: true

class AnnouncementCallbacks
  def after_create(announce)
    return if announce.wip?

    notify_to_slack(announce)
    send_notification(announce)
    announce.published_at = Time.current
    announce.save
  end

  def after_update(announce)
    return unless !announce.wip && announce.published_at.nil?

    notify_to_slack(announce)
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

  def notify_to_slack(announce)
    path = Rails.application.routes.url_helpers.polymorphic_path(announce)
    url = "https://bootcamp.fjord.jp#{path}"
    link = "<#{url}|#{announce.title}>"

    SlackNotification.notify link.to_s,
                             username: "#{announce.user.login_name} (#{announce.user.name})",
                             icon_url: announce.user.avatar_url,
                             channel: '#general',
                             attachments: [{
                               fallback: 'announcement description.',
                               text: announce.description
                             }]
  end

  def delete_notification(announce)
    Notification.where(path: "/announcements/#{announce.id}").destroy_all
  end
end
