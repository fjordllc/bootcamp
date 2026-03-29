# frozen_string_literal: true

class CreatePiyoChatMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :piyo_chat_messages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :textbook_section, null: false, foreign_key: { to_table: :textbook_sections }
      t.string :role, null: false
      t.text :content, null: false

      t.timestamps
    end

    add_index :piyo_chat_messages, %i[user_id textbook_section_id created_at],
              name: 'index_piyo_chat_messages_on_user_section_created'
  end
end
