# frozen_string_literal: true

class RemovePaperclipColumns < ActiveRecord::Migration[5.2]
  def change
    change_table :users, bulk: true do |t|
      t.remove :face_file_name
      t.remove :face_content_type
      t.remove :face_file_size
      t.remove :face_updated_at
    end

    change_table :images, bulk: true do |t|
      t.remove :image_file_name
      t.remove :image_content_type
      t.remove :image_file_size
      t.remove :image_updated_at
    end
  end
end
