# frozen_string_literal: true

require "stripe"

Stripe.api_key = Rails.application.credentials.stripe&.dig(:secret_key) || ENV['STRIPE_SECRET_KEY'] || (Rails.env.test? ? 'sk_test_XLP1Ajz1JvT9jUt5uKGvL0Wd' : nil)
Stripe.api_version = "2018-11-08"
