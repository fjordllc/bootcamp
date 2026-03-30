# frozen_string_literal: true

require_relative '../stripe_setup'

namespace :stripe do
  desc 'Stripeテスト環境にProduct/Plan/TaxRate/Customer/Subscriptionを作成し、developmentのDBと同期する'
  task setup: :environment do
    abort 'stripe:setup はこの環境では実行できません（development or staging + sk_test_ キーが必要です）' unless StripeSetup.executable?

    puts '🔄 Stripeテスト環境のセットアップを開始...'
    puts ''

    resources = StripeSetup.ensure_resources
    StripeSetup.sync_users(resources)
  end
end
