# frozen_string_literal: true

class AddKanaToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users, bulk: true do |t|
      t.string :kana_first_name, null: false, default: ''
      t.string :kana_last_name, null: false, default: ''
    end
  end
end
