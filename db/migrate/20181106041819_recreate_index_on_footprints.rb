# frozen_string_literal: true

class RecreateIndexOnFootprints < ActiveRecord::Migration[5.2]
  def change
    remove_index :footprints, column: [:user_id, :footprintable_id]
    add_index :footprints, [:user_id, :footprintable_id, :footprintable_type], name: "index_footprintable", unique: true
  end
end
