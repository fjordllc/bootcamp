# frozen_string_literal: true

class RenameInnerNotificationsToNotifications < ActiveRecord::Migration[5.2]
  def change
    rename_table :inner_notifications, :notifications
  end
end
