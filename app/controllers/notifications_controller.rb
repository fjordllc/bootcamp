# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :set_my_notification, only: %i[show]

  def index
    @target = params[:target]
    @notifications = UserNotificationsQuery.new(
      user: current_user,
      target: params[:target],
      status: params[:status]
    ).call.page(params[:page])
  end

  def show
    link = @notification.read_attribute :link
    @notifications = current_user.notifications.where(link:)
    current_user.mark_all_as_read_and_delete_cache_of_unreads(target_notifications: @notifications)
    redirect_to link
  end

  private

  def set_my_notification
    @notification = current_user.notifications.find(params[:id])
  end
end
