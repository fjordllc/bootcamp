# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :require_login, only: %i(index show)
  before_action :set_my_notification, only: %i(show)

  def index
    @notifications = current_user.notifications.order(created_at: :desc).page(params[:page])
  end

  def show
    @notifications = current_user.notifications.where(path: @notification.path)
    @notifications.update_all(read: true, updated_at: Time.current)
    redirect_to @notification.path
  end

  private
    def set_my_notification
      @notification = current_user.notifications.find_by(id: params[:id])
    end
end
