# frozen_string_literal: true

class RemoveOldNameColumnsFromUsers < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      change_table :users, bulk: true do |t|
        dir.up do
          t.remove :first_name
          t.remove :last_name
          t.remove :kana_first_name, null: false, default: ''
          t.remove :kana_last_name, null: false, default: ''
        end

        dir.down do
          t.string :first_name
          t.string :last_name
          t.string :kana_first_name, null: false, default: ''
          t.string :kana_last_name, null: false, default: ''
        end
      end
    end
  end
end
