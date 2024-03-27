class AddNotNullConstraintToFAQCategoriesId < ActiveRecord::Migration[6.1]
  def change
    change_column_null :faqs, :faqs_categories_id, false
  end
end
