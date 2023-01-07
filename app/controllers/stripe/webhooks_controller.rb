# frozen_string_literal: true

class Stripe::WebhooksController < ApplicationController
  protect_from_forgery
  skip_before_action :require_login, raise: false
  skip_before_action :require_current_student, raise: false

  def create
    event = Webhook.construct_event(
      payload: request.body.read,
      signature: request.env['HTTP_STRIPE_SIGNATURE']
    )

    if event
      case event['type']
      when 'payment_intent.payment_failed'
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
