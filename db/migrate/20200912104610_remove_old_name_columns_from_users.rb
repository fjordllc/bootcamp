# frozen_string_literal: true

class RemoveOldNameColumnsFromUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.remove :first_name
      t.remove :last_name
      t.remove :kana_first_name, null: false, default: ""
      t.remove :kana_last_name, null: false, default: ""
    end
  end
end
