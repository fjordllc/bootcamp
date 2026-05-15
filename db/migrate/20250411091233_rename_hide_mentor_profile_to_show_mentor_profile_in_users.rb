class RenameHideMentorProfileToShowMentorProfileInUsers < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :hide_mentor_profile, :show_mentor_profile
  end
end
