class AddIndexToCategoriesPractices < ActiveRecord::Migration[6.1]
  def change
    add_index :categories_practices, :position
  end
end
