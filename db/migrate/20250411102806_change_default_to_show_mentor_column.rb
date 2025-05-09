class ChangeDefaultToShowMentorColumn < ActiveRecord::Migration[6.1]
  def change
    change_column_default :users, :show_mentor_profile, from: false, to: true
  end
end
