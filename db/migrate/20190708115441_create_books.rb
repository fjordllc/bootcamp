# frozen_string_literal: true

class CreateBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :isbn, null: false
      t.boolean :borrowed, null: false, default: false

      t.timestamps
    end
  end
end
