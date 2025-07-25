# frozen_string_literal: true

class Webhook
  class << self
    SECRET = ENV['STRIPE_ENDPOINT_SECRET']

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
