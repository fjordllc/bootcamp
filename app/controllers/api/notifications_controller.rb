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
end
