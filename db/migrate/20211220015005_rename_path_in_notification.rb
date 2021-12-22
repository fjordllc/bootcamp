class RenamePathInNotification < ActiveRecord::Migration[6.1]
  def change
    rename_column :notifications, :path, :link
  end
end
