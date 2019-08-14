# frozen_string_literal: true

class ChangeNotificationToInnerNotification < ActiveRecord::Migration[5.2]
  def change
    rename_table :notifications, :inner_notifications
  end
end
