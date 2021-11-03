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

  def after_destroy(announce)
    delete_notification(announce)
  end

  private

  def after_first_publish(announce)
    notify_to_chat(announce)
    send_notification(announce)
    announce.update(published_at: Time.current)
  end

  def send_notification(announce)
    target_users = User.announcement_receiver(announce.target)
    target_users.each do |target|
      NotificationFacade.post_announcement(announce, target) if announce.sender != target
    end
  end

  def notify_to_chat(announce)
    path = Rails.application.routes.url_helpers.polymorphic_path(announce)
    url = "https://bootcamp.fjord.jp#{path}"

    ChatNotifier.message(
      "お知らせ：「#{announce.title}」\r#{url}",
      webhook_url: ENV['DISCORD_ALL_WEBHOOK_URL']
    )
  end

  def delete_notification(announce)
    Notification.where(path: "/announcements/#{announce.id}").destroy_all
  end

  def create_author_watch(announce)
    Watch.create!(user: announce.user, watchable: announce)
  end
end
