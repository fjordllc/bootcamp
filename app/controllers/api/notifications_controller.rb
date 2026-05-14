# frozen_string_literal: true

class API::NotificationsController < API::BaseController
  def index
    target = params[:target].presence&.to_sym
    status = params[:status]

    @notifications = UserNotificationsQuery.new(user: current_user, target:, status:).call

    page = params[:page]
    return @notifications unless page

    per = params[:per]
    @notifications = per ? @notifications.page(page).per(per) : @notifications.page(page)
  end

  def read
    notification = current_user.notifications.find_by(id: params[:id])
    return render json: { message: '通知が見つかりません。' }, status: :not_found unless notification

    notification.update!(read: true)
    Cache.delete_mentioned_and_unread_notification_count(current_user.id)
    notification.reload
    render json: { id: notification.id, read: notification.read }, status: :ok
  end

  def read_by_category
    notifications = current_user.notifications.by_target(validated_target).unreads
    count = notifications.count
    current_user.mark_all_as_read_and_delete_cache_of_unreads(target_notifications: notifications)
    render json: { count: }, status: :ok
  end

  def read_all
    notifications = current_user.notifications.unreads
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
