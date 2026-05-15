class AddNotNullConstraintToNameInFAQCategories < ActiveRecord::Migration[6.1]
  def change
    change_column_null :faq_categories, :name, false
  end
end
