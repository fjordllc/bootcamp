class AddThumbnailImageUrlToExternalEntries < ActiveRecord::Migration[6.1]
  def change
    add_column :external_entries, :thumbnail_image_url, :string
  end
end
