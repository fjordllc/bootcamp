class RemoveOfficekeyPermissionFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :officekey_permission, :boolean
  end
end
