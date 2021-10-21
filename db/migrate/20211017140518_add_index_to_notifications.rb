class AddIndexToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_index :notifications, :created_at
  end
end
