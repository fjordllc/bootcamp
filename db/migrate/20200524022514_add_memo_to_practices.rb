# frozen_string_literal: true

class AddMemoToPractices < ActiveRecord::Migration[6.0]
  def change
    add_column :practices, :memo, :text
  end
end
