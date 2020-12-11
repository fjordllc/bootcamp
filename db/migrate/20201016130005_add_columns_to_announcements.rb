# frozen_string_literal: true

class AddColumnsToAnnouncements < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      change_table :announcements, bulk: true do |t|
        dir.up do
          t.boolean :wip, default: false, null: false
          t.datetime :published_at
        end

        dir.down do
          t.remove :wip
          t.remove :published_at
        end
      end
    end
  end
end
