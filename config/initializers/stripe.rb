# frozen_string_literal: true

require "stripe"

# テスト環境ではダミーのAPIキーを設定（VCRが実際のAPIリクエストをモックする）
Stripe.api_key = Rails.env.test? ? 'sk_test_dummy_key_for_vcr' : ENV['STRIPE_SECRET_KEY']
Stripe.api_version = "2018-11-08"
