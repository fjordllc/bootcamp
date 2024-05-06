class AddUniqueIndexToFaqsCategoriesName < ActiveRecord::Migration[6.1]
  def change
    add_index :faqs_categories, :name, unique: true
  end
end
