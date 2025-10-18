# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :set_my_notification, only: %i[show]

  def index
    @target = params[:target]
    target = params[:target].presence&.to_sym
    status = params[:status]

    latest_notifications = current_user.notifications
                                       .by_target(target)
                                       .by_read_status(status)
                                       .latest_of_each_link

    @notifications = Notification.with_avatar
                                 .from(latest_notifications, :notifications)
                                 .order(created_at: :desc)
                                 .page(params[:page])
                                 .per(20)
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
