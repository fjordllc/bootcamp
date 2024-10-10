class RenameFaqCategoriesToFAQCategories < ActiveRecord::Migration[6.1]
  def change
    rename_table :faq_categories, :faq_categories
  end
end
