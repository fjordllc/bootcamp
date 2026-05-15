class AddShowStudyStreakToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :show_study_streak, :boolean, default: false, null: false
  end
end
