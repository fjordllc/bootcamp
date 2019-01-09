# frozen_string_literal: true

class AddAttachmentFaceToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :face_file_name, :string
    add_column :users, :face_content_type, :string
    add_column :users, :face_file_size, :integer
    add_column :users, :face_updated_at, :datetime
  end
end
