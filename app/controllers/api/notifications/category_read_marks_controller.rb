# frozen_string_literal: true

class API::Notifications::CategoryReadMarksController < API::BaseController
  def update
    notifications = current_user.notifications.by_target(validated_target).unreads
    count = notifications.count
    current_user.mark_all_as_read_and_delete_cache_of_unreads(target_notifications: notifications)
    render json: { count: }, status: :ok
  end

  private

  def validated_target
    target = params[:target].presence&.to_sym
    Notification::TARGETS_TO_KINDS.key?(target) ? target : nil
  end
end
