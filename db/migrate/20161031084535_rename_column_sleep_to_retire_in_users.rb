class RenameColumnSleepToRetireInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :sleep, :retire
  end
end
