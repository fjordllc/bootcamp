class ChangeRecordTypeToActiveStorageAttachment < ActiveRecord::Migration[6.1]
  def up
    ActiveStorage::Attachment.where(record_type: "ReferenceBook").each do |active_storage_attachment|
      active_storage_attachment.update_attribute(:record_type, "Book")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
