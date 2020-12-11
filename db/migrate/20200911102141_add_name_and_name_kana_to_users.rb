# frozen_string_literal: true

class AddNameAndNameKanaToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :name, null: false, default: ''
      t.string :name_kana, null: false, default: ''
    end
  end
end
