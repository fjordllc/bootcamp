class AddUserToAnnouncements < ActiveRecord::Migration[5.2]
  def change
    add_reference :announcements, :user, foreign_key: true
  end
end
