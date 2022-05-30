class CreatePracticesBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :practices_books do |t|
      t.references :practice, foreign_key: true
      t.references :book, foreign_key: true
      t.boolean :must_read, default: false, null: false
      t.timestamps
    end
  end
end
