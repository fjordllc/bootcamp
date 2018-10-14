# frozen_string_literal: true

class AddAttachmentImageToImages < ActiveRecord::Migration[5.1]
  def change
    create_table :images do |t|
      t.attachment :image
      t.belongs_to :user, foreign_key: true
      t.text :image_meta

      t.timestamps
    end
  end
end
