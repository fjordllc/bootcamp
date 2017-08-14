class ChangeOptionToChecks < ActiveRecord::Migration[5.0]
  def change
    change_column :checks, :user_id, :integer, null: false
    change_column :checks, :report_id, :integer, null: false
  end
end
