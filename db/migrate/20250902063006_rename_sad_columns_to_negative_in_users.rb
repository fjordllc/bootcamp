class RenameSadColumnsToNegativeInUsers < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :sad_streak, :negative_streak
    rename_column :users, :last_sad_report_id, :last_negative_report_id
  end
end
