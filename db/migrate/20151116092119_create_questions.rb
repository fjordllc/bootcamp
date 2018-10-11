# frozen_string_literal: true

class CreateQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table :questions do |t|
      t.string :title
      t.text :description
      t.belongs_to :user, index: true
      t.boolean :resolve

      t.timestamps
    end
  end
end
