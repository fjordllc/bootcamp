class CreatePracticesMovies < ActiveRecord::Migration[6.1]
  def change
    create_table :practices_movies do |t|
      t.references :practice, foreign_key: true
      t.references :movie, foreign_key: true
      t.timestamps
    end
  end
end
