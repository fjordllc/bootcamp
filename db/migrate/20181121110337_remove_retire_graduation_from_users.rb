# frozen_string_literal: true

class RemoveRetireGraduationFromUsers < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      change_table :users, bulk: true do |t|
        dir.up do
          t.remove :retire
          t.remove :graduation
        end

        dir.down do
          t.boolean :retire, null: false, default: false
          t.boolean :graduation, null: false, default: false
        end
      end
    end
  end
end
