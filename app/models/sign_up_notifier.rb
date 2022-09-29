# frozen_string_literal: true

class SignUpNotifier
  def call(user)
    user.unsubscribe_email_token = SecureRandom.urlsafe_base64
  end
end
