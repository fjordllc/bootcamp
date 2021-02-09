# frozen_string_literal: true

class CreateReferenceBooks < ActiveRecord::Migration[6.0]
  def change
    create_table :reference_books do |t|
      t.string :title, null: false
      t.integer :price, null: false
      t.string :page_url, null: false
      t.references :practice, null: false, foreign_key: true

      t.timestamps
    end
  end
end
