# frozen_string_literal: true

require "stripe"

# Load and symbolize secrets configuration
secrets_config = Rails.application.config_for(:secrets).deep_symbolize_keys

# Prefer ENV variable, fall back to config file
stripe_secret_key = ENV['STRIPE_SECRET_KEY'].presence ||
                   secrets_config.dig(:stripe, :secret_key)

# Fail fast if secret key is not configured
if stripe_secret_key.blank?
  raise KeyError, 'Stripe secret key is not configured. Set STRIPE_SECRET_KEY environment variable or stripe.secret_key in secrets.'
end

Stripe.api_key = stripe_secret_key
Stripe.api_version = "2018-11-08"
