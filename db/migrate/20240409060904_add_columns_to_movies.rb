class AddColumnsToMovies < ActiveRecord::Migration[6.1]
  def change
    add_column :movies, :wip, :boolean, null: false, default: false
    add_column :movies, :published_at, :datetime
  end
end
