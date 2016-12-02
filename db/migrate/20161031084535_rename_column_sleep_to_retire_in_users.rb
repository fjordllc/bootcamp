class RenameColumnSleepToRetireInUsers < ActiveRecord::Migration[4.2]
  def change
    rename_column :users, :sleep, :retire
  end
end
