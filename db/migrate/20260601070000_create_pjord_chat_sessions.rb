# frozen_string_literal: true

class CreatePjordChatSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :pjord_chat_sessions do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
