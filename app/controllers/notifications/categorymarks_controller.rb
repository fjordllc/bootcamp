# frozen_string_literal: true

class Notifications::CategorymarksController < ApplicationController
  def create
    target = params[:target].presence&.to_sym
    notifications = current_user.notifications.by_target(target).unreads
    notifications.update(read: true)
    redirect_to notifications_path(target: target), notice: '既読にしました'
  end
end
