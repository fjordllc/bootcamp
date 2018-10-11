# frozen_string_literal: true

class AddSleepToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :sleep, :boolean, null: false, default: false
  end
end
