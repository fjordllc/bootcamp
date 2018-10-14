# frozen_string_literal: true

class AddDescriptionToCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :categories, :description, :text
  end
end
