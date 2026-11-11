# frozen_string_literal: true

class UserRegistration
  Result = Struct.new(:success, :free, keyword_init: true) do
    def success?
      success
    end

    def free?
      free
    end
  end

  def initialize(user, stripe_token, idempotency_token, user_url, affiliate_rd_code)
    @user = user
    @stripe_token = stripe_token
    @idempotency_token = idempotency_token
    @user_url = user_url
    @affiliate_rd_code = affiliate_rd_code
  end

  def call
    if @user.staff? || @user.trainee?
      create_free_user!
    else
      create_user!
    end
  end

  private

  def create_free_user!
    Rails.logger.info "[Signup] 2. start create free user. #{@user.email}"

    return Result.new(success: false, free: true) unless @user.save

    Rails.logger.info "[Signup] 3. after save free user. #{@user.email}"

    complete_registration

    Rails.logger.info "[Signup] 4. after create times channel for free user. #{@user.email}"

    Result.new(success: true, free: true)
  end

  def create_user!
    result = PaidUserRegistration.call(
      user: @user,
      stripe_token: @stripe_token,
      idempotency_token: @idempotency_token
    )

    return Result.new(success: false, free: false) unless result.success?

    complete_registration
    send_affiliate_kickback

    Rails.logger.info "[Signup] 8. after create times channel. #{@user.email}"

    Result.new(success: true, free: false)
  end

  def complete_registration
    UserMailer.welcome(@user).deliver_now
    UserRegistrationNotifier.new.call(@user, @user_url)

    return unless @user.trainee? || @user.student?

    ActiveSupport::Notifications.instrument(
      'student_or_trainee.create',
      user: @user
    )
  end

  def send_affiliate_kickback
    return if @affiliate_rd_code.blank?

    AffiliateKickbackJob.perform_later(@user.id, @affiliate_rd_code)
  end
end
