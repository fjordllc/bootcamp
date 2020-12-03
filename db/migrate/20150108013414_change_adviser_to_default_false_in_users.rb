# frozen_string_literal: true

class ChangeAdviserToDefaultFalseInUsers < ActiveRecord::Migration[4.2]
  def up
    change_column :users, :adviser, :boolean, null: false, default: false
  end

  def down
    change_column :users, :adviser, :boolean, null: false, default: false
  end
end
