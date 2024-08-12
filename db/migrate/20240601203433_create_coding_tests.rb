class CreateCodingTests < ActiveRecord::Migration[6.1]
  def change
    create_table :coding_tests do |t|
      t.integer :language, null: false
      t.string :title, null: false
      t.text :description
      t.text :hint
      t.integer :position
      t.references :practice, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
