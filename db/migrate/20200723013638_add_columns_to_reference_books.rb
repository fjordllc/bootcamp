class AddColumnsToReferenceBooks < ActiveRecord::Migration[6.0]
  def change
    add_column :reference_books, :page_url, :string, null: false
    add_column :reference_books, :image_url, :string, null: false
  end
end
