# frozen_string_literal: true

class Stripe::WebhooksController < ApplicationController
  SECRET = Rails.application.config_for(:secrets)['stripe'][:endpoint_secret]
  ERROR_EVENTS = %w[
    payment_intent.payment_failed
    payment_intent.requires_payment_method
    payment_intent.canceled
    invoice.payment_failed
  ].freeze

  protect_from_forgery except: :create
  skip_before_action :require_active_user_login, raise: false

  def create
    event = Webhook.construct_event(
      payload: request.body.read,
      signature: request.env['HTTP_STRIPE_SIGNATURE'],
      endpoint_secret: SECRET
    )

    if event
      case event['type']
      when *ERROR_EVENTS
        intent = event['data']['object']
        message = <<~MESSAGE
          支払いが失敗しました。詳細は下記を参照してください。
          #{Webhook.intent_url(intent['id'])}
        MESSAGE
        DiscordNotifier.payment_failed({ body: message }).notify_now
      end

      head :ok
    else
      status 500
    end
  end
end
