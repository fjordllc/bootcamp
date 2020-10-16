class AddColumnsToAnnouncements < ActiveRecord::Migration[6.0]
  def change
    add_column :announcements, :wip, :boolean, default: false, null: false
    add_column :announcements, :published_at, :datetime
  end
end
