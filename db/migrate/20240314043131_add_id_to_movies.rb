class AddIdToMovies < ActiveRecord::Migration[6.1]
  def change
    add_reference :movies, :practices, foreign_key: true
  end
end
