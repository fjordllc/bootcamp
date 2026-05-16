# frozen_string_literal: true

class API::Notifications::AllReadMarksController < API::BaseController
  def update
    notifications = current_user.notifications.unreads
    count = notifications.count
    current_user.mark_all_as_read_and_delete_cache_of_unreads(target_notifications: notifications)
    render json: { count: }, status: :ok
  end
end
