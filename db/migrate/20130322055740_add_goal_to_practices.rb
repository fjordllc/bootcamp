class AddGoalToPractices < ActiveRecord::Migration[4.2]
  def change
    add_column :practices, :goal, :text
  end
end
