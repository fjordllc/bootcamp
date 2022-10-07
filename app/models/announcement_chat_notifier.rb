# frozen_string_literal: true

class AnnouncementChatNotifier
  def call(announce)
    path = Rails.application.routes.url_helpers.polymorphic_path(announce)
    url = "https://bootcamp.fjord.jp#{path}"

    ChatNotifier.message(
      "お知らせ：「#{announce.title}」\r#{url}",
      webhook_url: ENV['DISCORD_ALL_WEBHOOK_URL']
    )
  end
end
