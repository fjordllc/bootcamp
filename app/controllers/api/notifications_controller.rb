# frozen_string_literal: true

class API::NotificationsController < API::BaseController
  def index
    @notifications = UserNotificationsQuery.new(
      user: current_user,
      target: params[:target],
      status: params[:status]
    ).call

    page = params[:page]
    return @notifications unless page

    per = params[:per]
    @notifications = per ? @notifications.page(page).per(per) : @notifications.page(page)
  end
end
