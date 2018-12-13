# frozen_string_literal: true

class UserDeleter
  def initialize(user)
    @user = user
  end

  def delete
    @user.notifications.destroy_all
    @user.send_notifications.destroy_all
  end
end
