# frozen_string_literal: true

require "stripe"

Stripe.api_key = Rails.application.config_for(:secrets)[:stripe][:secret_key]
Stripe.api_version = "2018-11-08"
