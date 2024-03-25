class AddForeignKeyToFaqs < ActiveRecord::Migration[6.1]
  def change
    add_reference :faqs, :faqs_categories, foreign_key: true
  end
end
