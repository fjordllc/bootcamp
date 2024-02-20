class AddCategoryToFaqs < ActiveRecord::Migration[6.1]
  def change
    add_column :faqs, :category, :string
  end
end
