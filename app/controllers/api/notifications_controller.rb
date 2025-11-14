# frozen_string_literal: true

class Api::NotificationsController < Api::BaseController
  def index
    target = params[:target].presence&.to_sym
    status = params[:status]
    latest_notifications = current_user.notifications
                                       .by_target(target)
                                       .by_read_status(status)
                                       .latest_of_each_link

    # latest_notifications のクエリで指定している ORDER BY の順序を他と混ぜないようにするため、
    # from を使ってサブクエリとした
    @notifications = Notification.with_avatar
                                 .from(latest_notifications, :notifications)
                                 .order(created_at: :desc)

    page = params[:page]
    return @notifications unless page

    per = params[:per]
    @notifications = per ? @notifications.page(page).per(per) : @notifications.page(page)
  end
end
