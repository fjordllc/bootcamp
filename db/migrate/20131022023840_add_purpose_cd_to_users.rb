# frozen_string_literal: true

class AddPurposeCdToUsers < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :purpose_cd, :integer, default: 0, null: false
  end

  def down
    remove_column :users, :purpose_cd
  end
end
