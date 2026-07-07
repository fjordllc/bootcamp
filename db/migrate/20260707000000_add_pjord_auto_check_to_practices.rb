# frozen_string_literal: true

class AddPjordAutoCheckToPractices < ActiveRecord::Migration[8.0]
  def change
    add_column :practices, :pjord_auto_check, :boolean, null: false, default: false
  end
end
