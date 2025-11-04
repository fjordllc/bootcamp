# frozen_string_literal: true

class Stripe::WebhooksController < ApplicationController
  # Prefer ENV variable, fall back to config file
  secret_value = ENV['STRIPE_ENDPOINT_SECRET'].presence ||
                 Rails.application.config_for(:secrets).deep_symbolize_keys.dig(:stripe, :endpoint_secret)

  # Fail fast if secret is not configured
  raise KeyError, 'Stripeの:endpoint_secretが未設定です' if secret_value.blank?

  SECRET = secret_value.freeze
  private_constant :SECRET
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
