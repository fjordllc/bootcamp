class RemoveTagListFromMovies < ActiveRecord::Migration[6.1]
  def change
    remove_column :movies, :tag_list, :string
  end
end
