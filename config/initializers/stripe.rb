# frozen_string_literal: true

require "stripe"

stripe_config = Rails.application.config_for(:secrets)[:stripe]
Stripe.api_key = stripe_config[:secret_key]
Stripe.api_version = "2018-11-08"
