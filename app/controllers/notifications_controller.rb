# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :require_login, only: %i[index show]
  before_action :set_my_notification, only: %i[show]

  def index
    @target = params[:target]
  end

  def show
    path = @notification.read_attribute :path
    @notifications = current_user.notifications.where(path: path)
    @notifications.update(read: true)
    redirect_to path
  end

  private

  def set_my_notification
    @notification = current_user.notifications.find(params[:id])
  end
end
