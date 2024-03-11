class CreateMovies < ActiveRecord::Migration[6.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.text :description
      t.string :tags
      t.integer :public_scope

      t.timestamps
    end
  end
end
