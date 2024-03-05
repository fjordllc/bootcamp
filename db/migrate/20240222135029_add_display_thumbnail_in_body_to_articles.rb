class AddDisplayThumbnailInBodyToArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :articles, :display_thumbnail_in_body, :boolean, default: true, null: false
  end
end
