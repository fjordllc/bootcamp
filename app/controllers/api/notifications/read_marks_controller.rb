# frozen_string_literal: true

class API::Notifications::ReadMarksController < API::BaseController
  def update
    notification = current_user.notifications.find_by(id: params[:notification_id])
    return render json: { message: '通知が見つかりません。' }, status: :not_found unless notification

    notification.update!(read: true)
    Cache.delete_mentioned_and_unread_notification_count(current_user.id)
    notification.reload
    render json: { id: notification.id, read: notification.read }, status: :ok
  end
end
