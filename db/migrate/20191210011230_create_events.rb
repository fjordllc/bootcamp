# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :location, null: false
      t.integer :capacity, null: false
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.datetime :open_start_at, null: false
      t.datetime :open_end_at, null: false
      t.references :user

      t.timestamps
    end
  end
end
