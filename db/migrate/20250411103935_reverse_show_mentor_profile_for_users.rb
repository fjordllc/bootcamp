class ReverseShowMentorProfileForUsers < ActiveRecord::Migration[6.1]
  def up
    execute "UPDATE users SET show_mentor_profile = NOT show_mentor_profile"
  end

  def down
    execute "UPDATE users SET show_mentor_profile = NOT show_mentor_profile"
  end
end
