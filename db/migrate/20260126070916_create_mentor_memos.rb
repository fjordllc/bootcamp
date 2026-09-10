class CreateMentorMemos < ActiveRecord::Migration[8.1]
  def change
    create_table :mentor_memos do |t|
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :writer, null: false, foreign_key: { to_table: :users }
      t.text :body, null: false

      t.timestamps
    end
  end
end
