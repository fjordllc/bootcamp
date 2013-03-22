class AddGoalToPractices < ActiveRecord::Migration
  def change
    add_column :practices, :goal, :text
  end
end
