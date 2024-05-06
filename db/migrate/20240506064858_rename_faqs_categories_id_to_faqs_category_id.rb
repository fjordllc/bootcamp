class RenameFaqsCategoriesIdToFaqsCategoryId < ActiveRecord::Migration[6.1]
  def change
    rename_column :faqs, :faqs_categories_id, :faqs_category_id
  end
end
