# frozen_string_literal: true

class API::NotificationsController < API::BaseController
  def index
    @notifications = current_user.notifications.unreads_with_avatar
  end
end
