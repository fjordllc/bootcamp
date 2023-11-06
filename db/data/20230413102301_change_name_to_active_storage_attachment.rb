# frozen_string_literal: true

class ChangeNameToActiveStorageAttachment < ActiveRecord::Migration[6.1]
  def up
    ActiveStorage::Attachment.where(name: 'ogp_image', record_type: 'Practice').find_each do |record|
      record.update!(name: 'completion_image')
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
