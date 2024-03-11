class AddHideMentorProfileToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :hide_mentor_profile, :boolean, default: false, null: false
  end
end
