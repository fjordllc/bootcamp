# frozen_string_literal: true

class API::NotificationsController < API::BaseController
  def index
    target = params[:target].presence&.to_sym
    status = params[:status]

    @notifications = current_user.notifications
                                 .includes(sender: [:company])
                                 .by_target(target)
                                 .by_read_status(status)
                                 .order(created_at: :desc)

    @notifications = params[:page] ? @notifications.page(params[:page]) : @notifications
  end
end
