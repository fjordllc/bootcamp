class RemoveDuplicateAnnouncementsIndex < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    if index_name_exists?(:announcements, 'index_announcements_on_title')
      remove_index :announcements, name: 'index_announcements_on_title', algorithm: :concurrently
    end
  end

  def down
    return if index_name_exists?(:announcements, 'index_announcements_on_title')
    add_index :announcements, :title, name: 'index_announcements_on_title', algorithm: :concurrently
  end
end
