class AddTaskToPractices < ActiveRecord::Migration[5.1]
  def change
    add_column :practices, :task, :boolean, default: false, null: false
  end
end
