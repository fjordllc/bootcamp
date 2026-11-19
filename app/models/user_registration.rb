# frozen_string_literal: true

class UserRegistration
  Result = Struct.new(:success, :free, :user, keyword_init: true) do
    def success?
      success
    end

    def free?
      free
    end
  end

  def initialize(user_params:, registration_invitation:, payment_params:, affiliate_rd_code:)
    @user_params = user_params
    @registration_invitation = registration_invitation
    @credit_card_payment = payment_params[:credit_card_payment]
    @stripe_token = payment_params[:stripe_token]
    @idempotency_token = payment_params[:idempotency_token]
    @affiliate_rd_code = affiliate_rd_code
  end

  def call
    @user = build_user

    if @user.staff? || @user.trainee?
      create_free_user!
    else
      create_user!
    end
  end

  private

  def create_free_user!
    Rails.logger.info "[Signup] 2. start create free user. #{@user.email}"

    return Result.new(success: false, free: true, user: @user) unless @user.save

    Rails.logger.info "[Signup] 3. after save free user. #{@user.email}"

    complete_registration

    Rails.logger.info "[Signup] 4. after create times channel for free user. #{@user.email}"

    Result.new(success: true, free: true, user: @user)
  end

  def create_user!
    result = PaidUserRegistration.call(
      user: @user,
      stripe_token: @stripe_token,
      idempotency_token: @idempotency_token
    )

    return Result.new(success: false, free: false, user: @user) unless result.success?

    complete_registration
    send_affiliate_kickback

    Rails.logger.info "[Signup] 8. after create times channel. #{@user.email}"

    Result.new(success: true, free: false, user: @user)
  end

  def complete_registration
    UserMailer.welcome(@user).deliver_now
    user_url = Rails.application.routes.url_helpers.user_url(@user)
    UserRegistrationNotifier.new.call(@user, user_url)

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

  def build_user
    user = User.new(@user_params)
    user.assign_attributes(@registration_invitation.claims) if @registration_invitation
    user.assign_role
    user.course_id ||= Course.first.id
    user.build_discord_profile
    user.credit_card_payment = @credit_card_payment
    user.uploaded_avatar = @user_params[:avatar]
    user.unsubscribe_email_token = SecureRandom.urlsafe_base64
    user
  end
end
