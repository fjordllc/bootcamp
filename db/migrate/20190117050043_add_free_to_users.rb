# frozen_string_literal: true

class AddFreeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :free, :boolean, default: false, null: false
  end
end
