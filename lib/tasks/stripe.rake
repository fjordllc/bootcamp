# frozen_string_literal: true

require_relative '../stripe_setup'

namespace :stripe do
  desc 'Stripeテスト環境にProduct/Plan/TaxRate/Customer/Subscriptionを作成し、developmentのDBと同期する'
  task setup: :environment do
    abort 'このタスクはtest環境では実行できません' if Rails.env.test?
    abort 'このタスクはStripeテスト環境でのみ実行できます（sk_test_キーが必要です）' unless Stripe.api_key&.start_with?('sk_test_')

    puts '🔄 Stripeテスト環境のセットアップを開始...'
    puts ''

    resources = StripeSetup.ensure_resources
    StripeSetup.sync_users(resources)
  end
end
