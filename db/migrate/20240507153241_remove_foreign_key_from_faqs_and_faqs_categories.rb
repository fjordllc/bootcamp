class RemoveForeignKeyFromFaqsAndFaqsCategories < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :faqs, :faqs_categories
  end
end
