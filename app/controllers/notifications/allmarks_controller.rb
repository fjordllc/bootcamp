# frozen_string_literal: true

class Notifications::AllmarksController < ApplicationController
  def create
    @notifications = current_user.notifications
    @notifications.update_all(read: true, updated_at: Time.current)
    redirect_to notifications_path, notice: "全て既読にしました"
  end
end
