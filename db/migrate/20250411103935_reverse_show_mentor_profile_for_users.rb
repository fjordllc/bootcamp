class ReverseShowMentorProfileForUsers < ActiveRecord::Migration[6.1]
  def up
    User.update_all("show_mentor_profile = NOT show_mentor_profile")
  end

  def down
    User.update_all("show_mentor_profile = NOT show_mentor_profile")
  end
end
