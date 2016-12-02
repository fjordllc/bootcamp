class AddCategoryIdToPractices < ActiveRecord::Migration[4.2]
  def change
    add_reference :practices, :category, index: true
  end
end
