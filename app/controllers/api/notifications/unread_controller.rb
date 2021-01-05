# frozen_string_literal: true

class API::Notifications::UnreadController < API::BaseController
  def index
    @notifications = if params[:page]
                       current_user.notifications
                                   .unreads_with_avatar
                                   .order(created_at: :desc)
                                   .page(params[:page])
                     else
                       current_user.notifications.unreads_with_avatar
                     end
    render template: 'api/notifications/index'
  end
end
