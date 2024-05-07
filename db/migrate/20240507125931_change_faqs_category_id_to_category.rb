class ChangeFaqsCategoryIdToCategory < ActiveRecord::Migration[6.1]
  def change
    rename_column :faqs, :faqs_category_id, :category
    change_column :faqs, :category, :integer, null: false
  end
end
