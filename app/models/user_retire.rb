# frozen_string_literal: true

class UserRetire
  def initialize(user)
    @user = user
  end

  def retire
    @user.notifications.destroy_all
    @user.send_notifications.destroy_all
  end
end
