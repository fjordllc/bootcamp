class CreateCodingTestSubmissions < ActiveRecord::Migration[6.1]
  def change
    create_table :coding_test_submissions do |t|
      t.text :code, null: false
      t.references :coding_test, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :coding_test_submissions, [:coding_test_id, :user_id], unique: true
  end
end
