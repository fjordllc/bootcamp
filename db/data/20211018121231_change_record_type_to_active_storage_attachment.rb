# frozen_string_literal: true

class ChangeRecordTypeToActiveStorageAttachment < ActiveRecord::Migration[6.1]
  def up
    ActiveStorage::Attachment.where(record_type: 'ReferenceBook').each do |active_storage_attachment|
      active_storage_attachment.update(record_type: 'Book')
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
