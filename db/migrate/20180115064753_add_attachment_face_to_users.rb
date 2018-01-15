class AddAttachmentFaceToUsers < ActiveRecord::Migration[5.1]
  def change
    add_attachment :users, :face
  end
end
