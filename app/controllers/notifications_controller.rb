# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :require_login, only: %i[index show]
  before_action :set_my_notification, only: %i[show]

  def index
    @target = params[:target]
  end

  def show
    link = @notification.read_attribute :link
    @notifications = current_user.notifications.where(link: link)
    current_user.mark_all_as_read_and_delete_cache_of_unreads(target_notifications: @notifications)
    redirect_to link
  end

  private

  def set_my_notification
    @notification = current_user.notifications.find(params[:id])
  end
end
