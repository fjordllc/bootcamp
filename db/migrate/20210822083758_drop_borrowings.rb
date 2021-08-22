class DropBorrowings < ActiveRecord::Migration[6.1]
  def change
    drop_table :borrowings do |t|
      t.bigint :user_id
      t.bigint :book_id
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
