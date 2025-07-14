class RevertNegativeToSadColumnsOnUsers < ActiveRecord::Migration[6.1]
  def change
    # negative系のカラムを削除（あれば）
    remove_column :users, :last_negative_report_id if column_exists?(:users, :last_negative_report_id)
    remove_column :users, :negative_streak if column_exists?(:users, :negative_streak)

    # sad系のカラムを追加（なければ）
    add_column :users, :last_sad_report_id, :integer unless column_exists?(:users, :last_sad_report_id)
    add_column :users, :sad_streak, :boolean, default: false, null: false unless column_exists?(:users, :sad_streak)
  end
end
