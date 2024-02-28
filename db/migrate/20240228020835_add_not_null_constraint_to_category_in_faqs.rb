class AddNotNullConstraintToCategoryInFaqs < ActiveRecord::Migration[6.1]
  def change
    change_column_null :faqs, :category, false
  end
end
