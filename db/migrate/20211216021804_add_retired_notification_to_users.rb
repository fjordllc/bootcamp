class AddRetiredNotificationToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :retired_notification, :boolean, default: false, null: false
    User.retired.find_each do |retired_user|
      retired_user.update!(retired_notification: true) if retired_user.retired_on <= Date.current.prev_month(n = 3)
    end
  end
end
