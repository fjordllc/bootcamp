class RenameFAQCategoriesIdToFAQCategoryId < ActiveRecord::Migration[6.1]
  def change
    rename_column :faqs, :faq_categories_id, :faq_category_id
  end
end
