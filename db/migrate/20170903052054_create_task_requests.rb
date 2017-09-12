class CreateTaskRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :task_requests do |t|
      t.references :user, foreign_key: true, null: false
      t.references :practice, foreign_key: true, null: false
      t.text :content, null: false
      t.boolean :passed, default: false, null: false
      t.timestamps
    end
    add_index :task_requests, :passed
    add_index :task_requests, [:user_id, :practice_id], unique: true
  end
end
