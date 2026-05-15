# frozen_string_literal: true

class DropPagesBackupVimeoConversion < ActiveRecord::Migration[7.2]
  def up
    drop_table :pages_backup_vimeo_conversion, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
