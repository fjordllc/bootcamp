class RemovePositionFromCategories < ActiveRecord::Migration[6.1]
  def change
    remove_index :categories, :position
    remove_column :categories, :position, :integer
  end
end
