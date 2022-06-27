class AddSadStreakToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :sad_streak, :boolean, default: false, null: false
  end
end
