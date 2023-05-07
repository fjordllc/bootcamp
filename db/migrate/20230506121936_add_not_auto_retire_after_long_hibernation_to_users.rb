class AddNotAutoRetireAfterLongHibernationToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :not_auto_retire_after_long_hibernation, :boolean, default: false
  end
end
