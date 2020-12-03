# frozen_string_literal: true

class RemovePurposeCdFromUsers < ActiveRecord::Migration[5.2]
  def up
    remove_column :users, :purpose_cd
  end

  def down
    add_column :users, :purpose_cd, :integer, default: 0, null: false
  end
end
