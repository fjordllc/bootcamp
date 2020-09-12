# frozen_string_literal: true

class RemoveOldNameColumnsFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :first_name, :string
    remove_column :users, :last_name, :string
    remove_column :users, :kana_first_name, :string, null: false, default: ""
    remove_column :users, :kana_last_name, :string, null: false, default: ""
  end
end
