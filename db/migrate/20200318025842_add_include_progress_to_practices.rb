# frozen_string_literal: true

class AddIncludeProgressToPractices < ActiveRecord::Migration[6.0]
  def change
    add_column :practices, :include_progress, :boolean, null: false, default: true
  end
end
