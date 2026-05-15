# frozen_string_literal: true

class AddColumnsToCategoriesPractices < ActiveRecord::Migration[6.0]
  def change
    change_table :categories_practices, bulk: true do |t|
      t.primary_key :id
      t.integer :position
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
