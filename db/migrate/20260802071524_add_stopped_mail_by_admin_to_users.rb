class AddStoppedMailByAdminToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :stopped_mail_by_admin, :boolean, null: false, default: false
  end
end
