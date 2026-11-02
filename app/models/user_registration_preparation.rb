# frozen_string_literal: true

class UserRegistrationPreparation
  def initialize(user_params:, registration_invitation:, credit_card_payment:)
    @user_params = user_params
    @registration_invitation = registration_invitation
    @credit_card_payment = credit_card_payment
  end

  def call
    user = User.new(@user_params)
    user.assign_attributes(@registration_invitation) if @registration_invitation
    user.assign_role
    user.course_id ||= Course.first.id
    user.build_discord_profile
    user.credit_card_payment = @credit_card_payment
    user.uploaded_avatar = @user_params[:avatar]
    user.unsubscribe_email_token = SecureRandom.urlsafe_base64
    user
  end
end
