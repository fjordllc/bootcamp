class AddAssignmentToPractices < ActiveRecord::Migration[5.1]
  def change
    add_column :practices, :assignment, :boolean, default: false, null: false
  end
end
