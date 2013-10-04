class AddCategoryIdToPractices < ActiveRecord::Migration
  def change
    add_reference :practices, :category, index: true
  end
end
