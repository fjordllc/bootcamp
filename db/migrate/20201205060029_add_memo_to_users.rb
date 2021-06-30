# frozen_string_literal: true

class AddMemoToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :memo, :text
  end
end
