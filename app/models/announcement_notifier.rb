# frozen_string_literal: true

class AnnouncementNotifier
  def call(announce)
    path = Rails.application.routes.url_helpers.polymorphic_path(announce)
    url = "https://bootcamp.fjord.jp#{path}"

    ChatNotifier.message(
      "お知らせ：「#{announce.title}」\r#{url}",
      webhook_url: ENV['DISCORD_ALL_WEBHOOK_URL']
    )

    target_users = User.announcement_receiver(announce.target)
    target_users.each do |target|
      NotificationFacade.post_announcement(announce, target) if announce.sender != target
    end
  end
end
