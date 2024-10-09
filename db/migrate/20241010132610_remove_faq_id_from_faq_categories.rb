class RemoveFAQIdFromFAQCategories < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :faq_categories, :faqs
    remove_column :faq_categories, :faq_id
  end
end
