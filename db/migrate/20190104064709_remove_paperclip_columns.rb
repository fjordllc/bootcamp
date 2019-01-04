# frozen_string_literal: true

class RemovePaperclipColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :face_file_name
    remove_column :users, :face_content_type
    remove_column :users, :face_file_size
    remove_column :users, :face_updated_at

    remove_column :images, :image_file_name
    remove_column :images, :image_content_type
    remove_column :images, :image_file_size
    remove_column :images, :image_updated_at
  end
end
