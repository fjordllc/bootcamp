# frozen_string_literal: true

namespace :stripe do
  desc "Stripeテスト環境にProduct/Plan/TaxRate/Customer/Subscriptionを作成し、developmentのDBと同期する"
  task setup: :environment do
    if Rails.env.test?
      abort "このタスクはtest環境では実行できません"
    end

    if Rails.env.production? && !Stripe.api_key&.start_with?("sk_test_")
      abort "このタスクはStripeテスト環境でのみ実行できます（本番キーが検出されました）"
    end

    puts "🔄 Stripeテスト環境のセットアップを開始..."
    puts ""

    ensure_stripe_resources
    sync_users
  end
end

def ensure_stripe_resources
  puts "── Stripeリソースの確認 ──"

  # Product
  products = Stripe::Product.list(limit: 100).data
  product = products.find { |p| p.name == "フィヨルドブートキャンプ利用料" }
  if product
    puts "  ✅ Product: #{product.name} (#{product.id}) [既存]"
  else
    product = Stripe::Product.create(name: "フィヨルドブートキャンプ利用料", type: "service")
    puts "  ✅ Product: #{product.name} (#{product.id}) [新規作成]"
  end

  # スタンダードプラン
  plans = Stripe::Plan.list(limit: 100).data
  standard = plans.find { |p| p.nickname == "スタンダードプラン" }
  if standard
    puts "  ✅ スタンダードプラン: ¥#{standard.amount}/#{standard.interval} (#{standard.id}) [既存]"
  else
    standard = Stripe::Plan.create(
      amount: 29_800, currency: "jpy", interval: "month",
      nickname: "スタンダードプラン", product: product.id, trial_period_days: 3
    )
    puts "  ✅ スタンダードプラン: ¥#{standard.amount}/#{standard.interval} (#{standard.id}) [新規作成]"
  end

  # 法人研修プラン
  corporate = plans.find { |p| p.nickname == "法人研修プラン" }
  if corporate
    puts "  ✅ 法人研修プラン: ¥#{corporate.amount}/#{corporate.interval} (#{corporate.id}) [既存]"
  else
    corporate = Stripe::Plan.create(
      amount: 99_800, currency: "jpy", interval: "month",
      nickname: "法人研修プラン", product: product.id
    )
    puts "  ✅ 法人研修プラン: ¥#{corporate.amount}/#{corporate.interval} (#{corporate.id}) [新規作成]"
  end

  # Tax Rate
  tax_rates = Stripe::TaxRate.list(limit: 100).data
  tax_rate = tax_rates.find { |t| t.display_name == "消費税" && t.percentage == 10.0 && t.active }
  if tax_rate
    puts "  ✅ Tax Rate: #{tax_rate.display_name} #{tax_rate.percentage}% (#{tax_rate.id}) [既存]"
  else
    tax_rate = Stripe::TaxRate.create(
      display_name: "消費税", percentage: 10.0, inclusive: true, country: "JP"
    )
    puts "  ✅ Tax Rate: #{tax_rate.display_name} #{tax_rate.percentage}% (#{tax_rate.id}) [新規作成]"
  end

  # secrets.ymlのtax_rate_idと一致するか確認
  configured_tax_rate_id = Rails.application.config_for(:secrets)[:stripe][:tax_rate_id]
  if configured_tax_rate_id != tax_rate.id
    puts ""
    puts "  ⚠️  secrets.ymlのtax_rate_id (#{configured_tax_rate_id}) とStripeのID (#{tax_rate.id}) が異なります。"
    puts "     secrets.ymlまたは環境変数 STRIPE_TAX_RATE_ID を更新してください。"
  end

  puts ""
end

def sync_users
  puts "── ユーザーの同期 ──"

  plan = Plan.standard_plan
  if plan.nil?
    abort "❌ Stripeに「スタンダードプラン」が見つかりません。"
  end

  users = User.where.not(customer_id: [nil, ""])
  puts "  📋 プラン: #{plan.nickname} (#{plan.id})"
  puts "  👥 対象ユーザー: #{users.count}人"
  puts ""

  users.find_each do |user|
    sync_stripe_customer(user, plan)
  end

  puts ""
  puts "✅ セットアップ完了！"
end

def sync_stripe_customer(user, plan)
  print "  #{user.login_name} (#{user.email})... "

  customer = find_or_create_customer(user)
  subscription = find_or_create_subscription(customer, plan)

  user.update_columns(
    customer_id: customer.id,
    subscription_id: subscription.id
  )

  puts "✅ customer=#{customer.id}, subscription=#{subscription.id}"
rescue Stripe::StripeError => e
  puts "❌ #{e.message}"
end

def find_or_create_customer(user)
  existing = Stripe::Customer.list(email: user.email, limit: 1).data.first
  return existing if existing

  Stripe::Customer.create(
    email: user.email,
    source: "tok_visa",
    name: user.name
  )
end

def find_or_create_subscription(customer, plan)
  existing = Stripe::Subscription.list(customer: customer.id, status: "active", limit: 1).data.first
  existing ||= Stripe::Subscription.list(customer: customer.id, status: "trialing", limit: 1).data.first
  return existing if existing

  tax_rate_id = Rails.application.config_for(:secrets)[:stripe][:tax_rate_id]
  Stripe::Subscription.create(
    customer: customer.id,
    items: [{ plan: plan.id, tax_rates: [tax_rate_id] }],
    trial_end: "now"
  )
end
