# frozen_string_literal: true

require "stripe"

Stripe.api_key = Rails.application.secrets[:stripe][:secret_key]
Stripe.api_version = "2018-11-08"
