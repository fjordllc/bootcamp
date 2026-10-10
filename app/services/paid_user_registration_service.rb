# frozen_string_literal: true

class PaidUserRegistrationService
  def initialize(user:, stripe_token:, idempotency_token:, user_url:)
    @user = user
    @stripe_token = stripe_token
    @idempotency_token = idempotency_token
    @user_url = user_url
  end

  # rubocop:disable Metrics/MethodLength, Metrics/BlockLength
  def call
    Rails.logger.info "[Signup] 2. start create user. #{@user.email}"

    return false unless @user.validate

    if Card.new.search(email: @user.email)
      Rails.logger.error '[Payment] 同じメールアドレスの顧客が既に登録済みです。'
      @user.errors.add :base, '同じメールアドレスの顧客が既に登録済みです。'
      return false
    end

    Rails.logger.info "[Signup] 3. before create subscription. #{@user.email}"

    begin
      customer = Card.new.create(@user, @stripe_token, @idempotency_token)
      subscription = Subscription.new.create(
        customer['id'],
        "#{@idempotency_token}-subscription"
      )
    rescue Stripe::CardError => e
      Rails.logger.error "[Payment] customerの作成時にエラーが発生しました: #{e.message}"
      @user.errors.add :base, I18n.translate("stripe.errors.#{e.code}")
      return false
    end

    Rails.logger.info "[Signup] 4. after create subscription.#{@user.email}"

    @user.customer_id = customer['id']
    @user.subscription_id = subscription['id']

    return false unless @user.save

    Rails.logger.info "[Signup] 5. after save user. #{@user.email}"

    UserMailer.welcome(@user).deliver_now

    if @user.student?
      ActiveSupport::Notifications.instrument(
        'student_or_trainee.create',
        user: @user
      )
    end

    Rails.logger.info "[Signup] 8. after create times channel. #{@user.email}"

    true
  end
    # rubocop:enable Metrics/MethodLength, Metrics/BlockLength
end
