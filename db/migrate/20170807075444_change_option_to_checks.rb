# frozen_string_literal: true

class ChangeOptionToChecks < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      change_table :checks, bulk: true do |t|
        dir.up do
          t.change :user_id, :integer, null: false
          t.change :report_id, :integer, null: false
        end

        dir.down do
          t.change :user_id, :integer, null: true
          t.change :report_id, :integer, null: true
        end
      end
    end
  end
end
