# frozen_string_literal: true

class AddKanaToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :kana_first_name, :string, null: false, default: ""
    add_column :users, :kana_last_name, :string, null: false, default: ""
  end
end
