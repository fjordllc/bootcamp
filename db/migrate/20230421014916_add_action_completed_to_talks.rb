class AddActionCompletedToTalks < ActiveRecord::Migration[6.1]
  def change
    add_column :talks, :action_completed, :boolean, null: false, default: true
  end
end
