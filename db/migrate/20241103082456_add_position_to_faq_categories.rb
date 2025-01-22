class AddPositionToFAQCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :faq_categories, :position, :integer
  end
end
