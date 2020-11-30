# frozen_string_literal: true

class AddColumnsToAnnouncements < ActiveRecord::Migration[6.0]
  change_table :announcements, bulk: true do |t|
    t.boolean :wip, default: false, null: false
    t.datetime :published_at
  end
end
