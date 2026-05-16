# frozen_string_literal: true

class AddUniqueIndexToTextbookChaptersOnTextbookIdAndPosition < ActiveRecord::Migration[8.1]
  def change
    add_index :textbook_chapters, %i[textbook_id position], unique: true
  end
end
