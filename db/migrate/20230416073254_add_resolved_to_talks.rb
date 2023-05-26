class AddResolvedToTalks < ActiveRecord::Migration[6.1]
  def change
    add_column :talks, :resolved, :boolean, default: false, null: false
  end
end
