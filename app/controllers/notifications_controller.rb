# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :require_login, only: %i(show)
  before_action :set_my_notification, only: %i(show)

  def show
    @notifications = current_user.notifications.where(path: @notification.path)
    @notifications.update_all(read: true)
    redirect_to @notification.path
  end

  private
    def set_my_notification
      @notification = current_user.notifications.find_by(id: params[:id])
    end
end
