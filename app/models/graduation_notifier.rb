# frozen_string_literal: true

class GraduationNotifier
  def call(payload)
    user = payload[:user]
    User.mentor.each do |mentor|
      ActivityDelivery.with(sender: user, receiver: mentor).notify(:graduated)
    end

    DiscordNotifier.graduated(
      sender: user,
      webhook_url: ENV['DISCORD_ADMIN_WEBHOOK_URL']
    ).notify_now

    DiscordNotifier.graduated(
      sender: user,
      webhook_url: ENV['DISCORD_MENTOR_WEBHOOK_URL']
    ).notify_now
  end
end
