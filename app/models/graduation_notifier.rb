# frozen_string_literal: true

class GraduationNotifier
  def call(user)
    User.mentor.each do |mentor|
      ActivityDelivery.with(sender: user, receiver: mentor).notify(:graduated)
    end

    DiscordNotifier.graduated(
      sender: user,
      webhook_url: Rails.application.secrets[:webhook][:admin]
    ).notify_now

    DiscordNotifier.graduated(
      sender: user,
      webhook_url: Rails.application.secrets[:webhook][:mentor]
    ).notify_now
  end
end
