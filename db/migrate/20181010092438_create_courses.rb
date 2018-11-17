# frozen_string_literal: true

class CreateCourses < ActiveRecord::Migration[5.2]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.text :description, null: false

      t.timestamps
    end
  end
end
