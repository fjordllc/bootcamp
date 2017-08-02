class CreateChecks < ActiveRecord::Migration[5.0]
  def change
    create_table :checks do |t|
      t.integer :user_id
      t.integer :report_id

      t.timestamps
    end
    add_index :checks, :user_id
    add_index :checks, :report_id
    add_index :checks, [:user_id, :report_id], unique: true
  end
end
