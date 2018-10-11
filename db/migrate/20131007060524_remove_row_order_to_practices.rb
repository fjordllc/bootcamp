# frozen_string_literal: true

class RemoveRowOrderToPractices < ActiveRecord::Migration[4.2]
  def change
    remove_column :practices, :row_order
  end
end
