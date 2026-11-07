# frozen_string_literal: true

class PaidUserRegistration
  include Interactor

  def call
    user = context.user

    Rails.logger.info "[Signup] 2. start create user. #{user.email}"

    user.with_lock do
      validate_user(user)
      create_subscription(user)
      save_user(user)
    end
  end

  private

  def validate_user(user)
    context.fail!(reason: :invalid_user) unless user.validate

    return unless Card.new.search(email: user.email)

    Rails.logger.error '[Payment] 同じメールアドレスの顧客が既に登録済みです。'
    user.errors.add :base, '同じメールアドレスの顧客が既に登録済みです。'
    context.fail!(reason: :duplicate_customer)
  end

  def create_subscription(user)
    token = context.idempotency_token

    Rails.logger.info "[Signup] 3. before create subscription. #{user.email}"

    begin
      customer = Card.new.create(user, context.stripe_token, token)
      subscription = Subscription.new.create(customer['id'], "#{token}-subscription")
    rescue Stripe::CardError => e
      Rails.logger.error "[Payment] customerの作成時にエラーが発生しました: #{e.message}"
      user.errors.add :base, I18n.translate("stripe.errors.#{e.code}")
      context.fail!(reason: :card_error)
    end

    Rails.logger.info "[Signup] 4. after create subscription. #{user.email}"

    user.customer_id = customer['id']
    user.subscription_id = subscription['id']
  end

  def save_user(user)
    context.fail!(reason: :save_failed) unless user.save

    Rails.logger.info "[Signup] 5. after save user. #{user.email}"
  end
end
