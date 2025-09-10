# frozen_string_literal: true

class GraduationNotifier
  def call(_name, _started, _finished, _unique_id, payload)
    user = payload[:user]
    User.mentor.each do |mentor|
      ActivityDelivery.with(sender: user, receiver: mentor).notify(:graduated)
    end

    DiscordNotifier.graduated(
      sender: user,
      webhook_url: webhook_url_for!(:admin)
    ).notify_now

    DiscordNotifier.graduated(
      sender: user,
      webhook_url: webhook_url_for!(:mentor)
    ).notify_now
  end

  private

  def webhook_url_for!(role)
    url = credentials_url(role) || secrets_url(role)
    return url unless url.nil? || url.to_s.strip.empty?

    raise KeyError, "Missing Discord webhook URL for '#{role}'. Configure credentials.webhook.#{role} or secrets.yml shared.webhook.#{role}."
  end

  def credentials_url(role)
    Rails.application.credentials.dig(:webhook, role)
  rescue StandardError
    nil
  end

  def secrets_url(role)
    cfg = Rails.application.config_for(:secrets)
    cfg.is_a?(Hash) ? (cfg.dig(:webhook, role) || cfg.dig('webhook', role.to_s)) : nil
  rescue StandardError
    nil
  end
end
