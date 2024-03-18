class RenamePracticesIdToPracticeIdInMovies < ActiveRecord::Migration[6.1]
  def change
    rename_column :movies, :practices_id, :practice_id
  end
end
