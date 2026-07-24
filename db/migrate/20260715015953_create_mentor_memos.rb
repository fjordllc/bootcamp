class CreateMentorMemos < ActiveRecord::Migration[8.1]
  def change
    create_table :mentor_memos do |t|
      t.references :user, null: false, foreign_key: true
      t.references :author, null: true, foreign_key: { to_table: :users }
      t.text :content, null: false
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end
end
