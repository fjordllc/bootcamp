# frozen_string_literal: true

class CreatePjordChatMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :pjord_chat_messages do |t|
      t.references :pjord_chat_session, null: false, foreign_key: true
      t.string :role, null: false
      t.text :body, null: false

      t.timestamps
    end

    add_index :pjord_chat_messages, %i[pjord_chat_session_id created_at]
    add_check_constraint :pjord_chat_messages, "role IN ('user', 'assistant')", name: 'pjord_chat_messages_role_check'
  end
end
