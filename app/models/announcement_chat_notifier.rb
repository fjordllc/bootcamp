# frozen_string_literal: true

class AnnouncementChatNotifier
  def call(announce)
    DiscordNotifier.with(announce: announce).announced.notify_now
  end
end
