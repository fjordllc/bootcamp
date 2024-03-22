class CreateMovies < ActiveRecord::Migration[6.1]
  def change
    create_table :movies do |t|
      t.string :title , null: false
      t.text :description
      t.string :tag_list
      t.references :user, foreign_key: true, null: false
      t.references :practice, foreign_key: true

      t.timestamps
    end
  end
end
