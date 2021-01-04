# frozen_string_literal: true

class API::NotificationsController < API::BaseController
  def index
    @notifications = current_user.notifications
                                 .reads_with_avatar
                                 .order(created_at: :desc)
                                 .page(params[:page])
  end
end
