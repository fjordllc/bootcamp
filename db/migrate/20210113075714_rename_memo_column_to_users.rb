# frozen_string_literal: true

class RenameMemoColumnToUsers < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :memo, :mentor_memo
  end
end
