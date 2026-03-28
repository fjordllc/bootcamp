# frozen_string_literal: true

namespace :stripe do
  desc "Stripeテスト環境にCustomer/Subscriptionを作成し、developmentのDBと同期する"
  task setup: :environment do
    unless Rails.env.development?
      abort "このタスクはdevelopment環境でのみ実行できます"
    end

    puts "🔄 Stripeテスト環境のセットアップを開始..."
    puts ""

    # customer_idを持つユーザーを対象にする
    users = User.where.not(customer_id: [nil, ""])
    plan = Plan.standard_plan

    if plan.nil?
      abort "❌ Stripeに「スタンダードプラン」が見つかりません。Stripeダッシュボードで作成してください。"
    end

    puts "📋 プラン: #{plan.nickname} (#{plan.id}) - ¥#{plan.amount}/#{plan.interval}"
    puts "👥 対象ユーザー: #{users.count}人"
    puts ""

    users.find_each do |user|
      sync_stripe_customer(user, plan)
    end

    puts ""
    puts "✅ セットアップ完了！"
  end
end

def sync_stripe_customer(user, plan)
  print "  #{user.login_name} (#{user.email})... "

  # 1. Customerを検索 or 作成
  customer = find_or_create_customer(user)

  # 2. Subscriptionを検索 or 作成
  subscription = find_or_create_subscription(customer, plan)

  # 3. DBを更新
  user.update_columns(
    customer_id: customer.id,
    subscription_id: subscription.id
  )

  puts "✅ customer=#{customer.id}, subscription=#{subscription.id}"
rescue Stripe::StripeError => e
  puts "❌ #{e.message}"
end

def find_or_create_customer(user)
  # メールで既存Customerを検索
  existing = Stripe::Customer.list(email: user.email, limit: 1).data.first
  return existing if existing

  # なければテストカード(tok_visa)で作成
  Stripe::Customer.create(
    email: user.email,
    source: "tok_visa",
    name: user.name
  )
end

def find_or_create_subscription(customer, plan)
  # 既存のアクティブ/トライアル中Subscriptionを検索
  existing = Stripe::Subscription.list(
    customer: customer.id,
    status: "active",
    limit: 1
  ).data.first

  existing ||= Stripe::Subscription.list(
    customer: customer.id,
    status: "trialing",
    limit: 1
  ).data.first

  return existing if existing

  # なければ作成（トライアルなしで即アクティブ）
  tax_rate_id = Rails.application.config_for(:secrets)[:stripe][:tax_rate_id]
  Stripe::Subscription.create(
    customer: customer.id,
    items: [{ plan: plan.id, tax_rates: [tax_rate_id] }],
    trial_end: "now"
  )
end
