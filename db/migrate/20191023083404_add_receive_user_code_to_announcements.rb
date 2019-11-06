# frozen_string_literal: true

class AddReceiveUserCodeToAnnouncements < ActiveRecord::Migration[5.2]
  def change
    add_column :announcements, :target, :integer, null: false, default: 0
  end
end
