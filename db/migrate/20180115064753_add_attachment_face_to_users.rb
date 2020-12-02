# frozen_string_literal: true

class AddAttachmentFaceToUsers < ActiveRecord::Migration[5.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :face_file_name
      t.string :face_content_type
      t.integer :face_file_size
      t.datetime :face_updated_at
    end
  end
end
