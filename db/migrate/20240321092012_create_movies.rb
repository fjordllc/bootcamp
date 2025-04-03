class CreateMovies < ActiveRecord::Migration[6.1]
  def change
    create_table :movies do |t|
      t.string :title , null: false
      t.text :description
      t.references :user, foreign_key: true, null: true

      t.timestamps
    end
  end
end
