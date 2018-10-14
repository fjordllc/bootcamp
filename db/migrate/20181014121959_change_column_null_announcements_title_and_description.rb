class ChangeColumnNullAnnouncementsTitleAndDescription < ActiveRecord::Migration[5.2]
  def change
    change_column_null :announcements, :title, false
    change_column_null :announcements, :description, false
  end
end
