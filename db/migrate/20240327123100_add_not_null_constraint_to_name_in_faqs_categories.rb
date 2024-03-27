class AddNotNullConstraintToNameInFaqsCategories < ActiveRecord::Migration[6.1]
  def change
    change_column_null :faqs_categories, :name, false
  end
end
