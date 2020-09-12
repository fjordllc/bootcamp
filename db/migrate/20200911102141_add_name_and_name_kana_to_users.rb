# frozen_string_literal: true

class AddNameAndNameKanaToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :name, :string, null: false, default: ""
    add_column :users, :name_kana, :string, null: false, default: ""
  end
end
