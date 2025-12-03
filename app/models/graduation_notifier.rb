# frozen_string_literal: true

class GraduationNotifier
  def call(_name, _started, _finished, _unique_id, payload)
    user = payload[:user]
    User.mentor.each do |mentor|
      ActivityDelivery.with(sender: user, receiver: mentor).notify(:graduated)
    end

    DiscordNotifier.graduated(
      sender: user,
      webhook_url: Rails.application.config_for(:secrets)[:webhook][:admin]
    ).notify_now

    DiscordNotifier.graduated(
      sender: user,
      webhook_url: Rails.application.config_for(:secrets)[:webhook][:mentor]
    ).notify_now
  end
end
