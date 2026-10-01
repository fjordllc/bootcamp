# frozen_string_literal: true

class CreateAiPrompts < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_prompts do |t|
      t.string :key, null: false
      t.text :body, null: false

      t.timestamps
    end

    add_index :ai_prompts, :key, unique: true
  end
end
