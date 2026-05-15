# frozen_string_literal: true

class Notification::RedirectorController < ApplicationController
  before_action :set_my_notification, only: %i[show]

  def show
    notifications = current_user.notifications.where(
      link: params[:link]
    )
    current_user.mark_all_as_read_and_delete_cache_of_unreads(
      target_notifications: notifications
    )
    redirect_to params[:link]
  end

  private

  def set_my_notification
    @notification = current_user.notifications.find_by(
      link: params[:link],
      kind: params[:kind]
    )
  end
end
