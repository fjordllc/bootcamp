# frozen_string_literal: true

class CreateReports < ActiveRecord::Migration[4.2]
  def change
    create_table :reports do |t|
      t.integer :user_id, null: false
      t.string :title, null: false, limit: 255
      t.text :description, null: true
      t.timestamps
    end
  end
end
