class DropFaqsCategories < ActiveRecord::Migration[6.1]
  def change
    drop_table :faqs_categories
  end
end
