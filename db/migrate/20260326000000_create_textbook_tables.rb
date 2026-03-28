# frozen_string_literal: true

class CreateTextbookTables < ActiveRecord::Migration[8.1]
  def change
    create_table :textbooks do |t|
      t.string :title, null: false
      t.text :description
      t.boolean :published, default: false, null: false
      t.references :practice, foreign_key: true, null: true
      t.timestamps
    end

    create_table :textbook_chapters do |t|
      t.references :textbook, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :position, null: false
      t.timestamps
    end

    create_table :textbook_sections do |t|
      t.references :textbook_chapter, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body, null: false
      t.integer :estimated_minutes
      t.text :goals, array: true, default: []
      t.text :key_terms, array: true, default: []
      t.integer :position, null: false
      t.timestamps
    end

    create_table :reading_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :textbook_section, null: false, foreign_key: true
      t.float :read_ratio, default: 0.0, null: false
      t.boolean :completed, default: false, null: false
      t.integer :last_block_index, default: 0
      t.datetime :last_read_at
      t.timestamps
      t.index %i[user_id textbook_section_id], unique: true
    end

    create_table :term_explanations do |t|
      t.references :textbook_section, null: false, foreign_key: true
      t.string :term, null: false
      t.text :explanation, null: false
      t.timestamps
      t.index %i[textbook_section_id term], unique: true
    end
  end
end
