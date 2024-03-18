class AddThumbnailToMovies < ActiveRecord::Migration[6.1]
  def change
    add_column :movies, :thumbnail, :string
  end
end
