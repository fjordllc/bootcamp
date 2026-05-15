class AddIndexToCategories < ActiveRecord::Migration[6.1]
  def change
    add_index :categories, :position
  end
end
