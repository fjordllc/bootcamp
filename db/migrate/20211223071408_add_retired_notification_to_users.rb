class AddRetiredNotificationToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :retired_notification, :boolean, default: false, null: false
  end
end
