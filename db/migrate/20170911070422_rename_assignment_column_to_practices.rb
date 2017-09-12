class RenameAssignmentColumnToPractices < ActiveRecord::Migration[5.1]
  def change
    rename_column :practices, :assignment, :has_task
  end
end
