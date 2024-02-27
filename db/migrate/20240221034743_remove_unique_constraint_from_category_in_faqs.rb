class RemoveUniqueConstraintFromCategoryInFaqs < ActiveRecord::Migration[6.1]
  def change
    remove_index :faqs, name: "index_faqs_on_category"
  end
end
