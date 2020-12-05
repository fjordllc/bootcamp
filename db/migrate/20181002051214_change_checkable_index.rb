# frozen_string_literal: true

class ChangeCheckableIndex < ActiveRecord::Migration[5.2]
  def up
    remove_index :checks, name: "index_checks_on_user_id_and_checkable_id"
    add_index :checks, [:user_id, :checkable_id, :checkable_type], unique: true
  end

  def down
    remove_index :checks, [:user_id, :checkable_id, :checkable_type]
    add_index :checks, %w[user_id checkable_id], name: "index_checks_on_user_id_and_checkable_id"
  end
end
