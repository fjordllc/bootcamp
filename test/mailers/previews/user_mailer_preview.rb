# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def reset_password_email
    user = User.first
    user.generate_reset_password_token!
    UserMailer.reset_password_email(user)
  end

  def welcome
    user = User.first
    UserMailer.welcome(user)
  end
end
