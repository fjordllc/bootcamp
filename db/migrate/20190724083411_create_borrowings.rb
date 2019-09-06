# frozen_string_literal: true

class CreateBorrowings < ActiveRecord::Migration[5.2]
  def change
    create_table :borrowings do |t|
      t.references :user, foreign_key: true
      t.references :book, foreign_key: true

      t.timestamps
    end
  end
end
