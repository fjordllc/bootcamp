class RemoveDuplicateAnnouncementsIndex < ActiveRecord::Migration[6.1]
  def change
    if index_name_exists?(:announcements, 'index_announcements_on_title')
      remove_index :announcements, name: 'index_announcements_on_title'
    end
  end
end
