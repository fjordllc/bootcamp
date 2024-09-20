class RemoveFreeFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :free, :boolean, default: false, null: false
  end
end
