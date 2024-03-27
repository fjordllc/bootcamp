# frozen_string_literal: true

class API::NotificationsController < API::BaseController
  def index
    @notifications = fetch_notifications
    paginate_notifications if params[:page]
  end

  private

  def fetch_notifications
    target = params[:target]
    status = params[:status]

    latest_notifications = current_user.notifications.by_target(target).by_read_status(status).latest_of_each_link

    # latest_notifications のクエリで指定している ORDER BY の順序を他と混ぜないようにするため、from を使ってサブクエリとした
    Notification.with_avatar.from(latest_notifications, :notifications).order(created_at: :desc)
  end

  def paginate_notifications
    per_page = params[:per]
    @notifications = per_page ? @notifications.page(params[:page]).per(per_page) : @notifications.page(params[:page])
  end
end
