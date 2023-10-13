class RenameCorrectColumnToStatements < ActiveRecord::Migration[6.1]
  def change
    rename_column :statements, :correct?, :is_correct
  end
end
