class CreateSkipPractices < ActiveRecord::Migration[6.1]
  def change
    create_table :skip_practices do |t|
      t.integer :user_id,     null: false
      t.integer :practice_id, null: false
      t.index %i[user_id practice_id], unique: true

      t.timestamps
    end
  end
end
