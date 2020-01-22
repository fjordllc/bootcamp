# frozen_string_literal: true

class Notifications::UnreadController < ApplicationController
  def index
    @notifications = current_user.notifications
                                 .unreads_with_avatar
                                 .order(created_at: :desc)
                                 .page(params[:page])
  end
end
