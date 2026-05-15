# frozen_string_literal: true

class AddIndexToMemos < ActiveRecord::Migration[6.0]
  def change
    add_index :memos, :date, unique: true
  end
end
