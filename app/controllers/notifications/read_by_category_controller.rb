# frozen_string_literal: true

class Notifications::ReadByCategoryController < ApplicationController
  def create
    target = params[:target].presence&.to_sym
    notifications = current_user.notifications.by_target(target).unreads
    current_user.mark_all_as_read_and_delete_cache_of_unreads(target_notifications: notifications)
    redirect_to notifications_path(target: target), notice: '既読にしました'
  end
end
