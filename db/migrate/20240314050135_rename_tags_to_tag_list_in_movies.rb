class RenameTagsToTagListInMovies < ActiveRecord::Migration[6.1]
  def change
    rename_column :movies, :tags, :tag_list
  end
end
