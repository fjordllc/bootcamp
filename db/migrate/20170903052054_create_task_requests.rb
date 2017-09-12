class CreateTaskRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :submissions do |t|
      t.references :user, foreign_key: true, null: false
      t.references :practice, foreign_key: true, null: false
      t.text :content, null: false
      t.boolean :passed, default: false, null: false
      t.timestamps
    end
    add_index :submissions, :passed
    add_index :submissions, [:user_id, :practice_id], unique: true
  end
end
