class AddThumbnailTypeToArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :articles, :thumbnail_type, :integer, null: false, default: 0
  end
end
