# frozen_string_literal: true

class AddIndexToProducts < ActiveRecord::Migration[6.0]
  def change
    add_index :products, [:user_id, :practice_id], unique: true
  end
end
