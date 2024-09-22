class RenameFaqsCategoriesToFAQCategories < ActiveRecord::Migration[6.1]
  def change
    rename_table :faqs_categories, :faq_categories
  end
end
