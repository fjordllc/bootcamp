class AddUniqueIndexToFAQCategoriesName < ActiveRecord::Migration[6.1]
  def change
    add_index :faq_categories, :name, unique: true
  end
end
