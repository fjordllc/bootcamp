# frozen_string_literal: true

class API::NotificationsController < API::BaseController
  def index
    target = params[:target].presence&.to_sym
    status = params[:status]
    latest_notifications = current_user.notifications
                                       .by_target(target)
                                       .by_read_status(status)
                                       .latest_of_each_link

    @notifications = Notification.from(latest_notifications, :notifications) # latest_notifications のクエリで指定している ORDER BY の順序を他と混ぜないようにするため、from を使ってサブクエリとした
                                 .order(created_at: :desc)
    @notifications = params[:page] ? @notifications.page(params[:page]) : @notifications
  end
end
