# frozen_string_literal: true

class SignUpNotifier
  def call(payload)
    user = payload[:user]
    user.unsubscribe_email_token = SecureRandom.urlsafe_base64
  end
end
