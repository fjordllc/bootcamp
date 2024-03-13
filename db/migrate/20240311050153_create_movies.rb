class CreateMovies < ActiveRecord::Migration[6.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.text :description
      t.string :tags
      t.integer :public_scope
      t.binary :movie_data
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end
  end
end
