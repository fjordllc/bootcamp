# frozen_string_literal: true

require "stripe"

Stripe.api_key = Rails.application.credentials.stripe&.dig(:secret_key) || ENV['STRIPE_SECRET_KEY']
Stripe.api_version = "2018-11-08"
