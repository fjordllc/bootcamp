# frozen_string_literal: true

class RecreateIndexOnFootprints < ActiveRecord::Migration[5.2]
  def change
    remove_index :footprints, column: %i[user_id footprintable_id]
    add_index :footprints, %i[user_id footprintable_id footprintable_type], name: 'index_footprintable', unique: true
  end
end
