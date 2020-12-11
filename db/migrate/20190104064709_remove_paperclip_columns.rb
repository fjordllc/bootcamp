# frozen_string_literal: true

class RemovePaperclipColumns < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      change_table :users, bulk: true do |t|
        dir.up do
          t.remove :face_file_name
          t.remove :face_content_type
          t.remove :face_file_size
          t.remove :face_updated_at
        end

        dir.down do
          t.string :face_file_name
          t.string :face_content_type
          t.integer :face_file_size
          t.datetime :face_updated_at
        end
      end
    end

    reversible do |dir|
      change_table :images, bulk: true do |t|
        dir.up do
          t.remove :image_file_name
          t.remove :image_content_type
          t.remove :image_file_size
          t.remove :image_updated_at
        end

        dir.down do
          t.string :image_file_name
          t.string :image_content_type
          t.integer :image_file_size
          t.datetime :image_updated_at
        end
      end
    end
  end
end
