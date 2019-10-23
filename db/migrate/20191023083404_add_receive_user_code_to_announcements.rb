# frozen_string_literal: true

class AddReceiveUserCodeToAnnouncements < ActiveRecord::Migration[5.2]
  def change
    add_column :announcements, :receive_user_code, :integer, null: false, default: 0
  end
end
