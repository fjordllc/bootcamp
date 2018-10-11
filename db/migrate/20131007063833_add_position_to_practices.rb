# frozen_string_literal: true

class AddPositionToPractices < ActiveRecord::Migration[4.2]
  def change
    add_column :practices, :position, :integer
  end
end
