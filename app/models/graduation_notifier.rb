# frozen_string_literal: true

class GraduationNotifier
  def call(user)
    User.mentor.each do |mentor|
      ActivityDelivery.with(sender: user, receiver: mentor).notify(:graduated)
    end

    admin_webhook_url = Rails.application.secrets[:webhook][:admin]
    DiscordNotifier.graduated(sender: user, webhook_url: admin_webhook_url).notify_now

    mentor_webhook_url = Rails.application.secrets[:webhook][:mentor]
    DiscordNotifier.graduated(sender: user, webhook_url: mentor_webhook_url).notify_now
  end
end
