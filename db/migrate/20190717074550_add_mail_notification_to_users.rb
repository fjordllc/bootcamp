class AddMailNotificationToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :mail_notification, :boolean, null: false, default: true
  end
end
