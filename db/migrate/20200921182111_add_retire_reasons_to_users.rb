# frozen_string_literal: true

class AddRetireReasonsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :retire_reasons, :integer, null: false, default: 0, limit: 8
  end
end
