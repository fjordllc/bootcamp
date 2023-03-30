# frozen_string_literal: true

class UserCallbacks
  def after_create(user)
    user.create_talk!
  end
end
