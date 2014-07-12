class AddSleepToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sleep, :boolean, null: false, default: false
  end
end
