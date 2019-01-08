# frozen_string_literal: true

class AddAttachmentImageToImages < ActiveRecord::Migration[5.1]
  def change
    create_table :images do |t|
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.belongs_to :user, foreign_key: true
      t.text :image_meta

      t.timestamps
    end
  end
end
