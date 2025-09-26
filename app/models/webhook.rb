# frozen_string_literal: true

class Webhook
  class << self
    # Prefer ENV variable, fall back to config file
    secret_value = ENV['STRIPE_ENDPOINT_SECRET'].presence ||
                   Rails.application.config_for(:secrets).deep_symbolize_keys.dig(:stripe, :endpoint_secret)

    # Fail fast if secret is not configured
    raise KeyError, 'Stripeの:endpoint_secretが未設定です' if secret_value.blank?

    SECRET = secret_value.freeze
    private_constant :SECRET

    def construct_event(
      payload:,
      signature:,
      endpoint_secret: SECRET
    )
      Stripe::Webhook.construct_event(
        payload,
        signature,
        endpoint_secret
      )
    rescue JSON::ParserError => e
      Rails.logger.warn(e)
      nil
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.warn(e)
      nil
    end

    def intent_url(intent_id)
      base_url = 'https://dashboard.stripe.com/'
      if Rails.env.production?
        "#{base_url}payments/#{intent_id}"
      else
        "#{base_url}test/payments/#{intent_id}"
      end
    end
  end
end
