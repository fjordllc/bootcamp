class RemoveForeignKeyFromFaqs < ActiveRecord::Migration[6.1]
  def down
    remove_foreign_key :faqs, column: :faqs_category_id
  end
end
