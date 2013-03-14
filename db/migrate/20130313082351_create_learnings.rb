class CreateLearnings < ActiveRecord::Migration
  def change
    create_table :learnings do |t|
      t.integer :user_id,     null: false
      t.integer :practice_id, null: false
      t.integer :status_cd,   null: false, default: 0

      t.timestamps
    end
  end
end
