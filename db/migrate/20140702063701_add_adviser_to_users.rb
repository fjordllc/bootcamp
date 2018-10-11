# frozen_string_literal: true

class AddAdviserToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :adviser, :boolean, default: false, null: false
  end
end
