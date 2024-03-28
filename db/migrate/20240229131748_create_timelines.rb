class CreateTimelines < ActiveRecord::Migration[6.1]
  def change
    create_table :timelines do |t|
      t.text :context
      t.integer :user_id, foreign_key: true, null: false
      t.timestamps
    end
  end
end
