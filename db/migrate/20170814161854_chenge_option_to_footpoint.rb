class ChengeOptionToFootpoint < ActiveRecord::Migration[5.1]
  def change
    change_column :footprints, :user_id, :integer, null: false
    change_column :footprints, :report_id, :integer, null: false
  end
end
