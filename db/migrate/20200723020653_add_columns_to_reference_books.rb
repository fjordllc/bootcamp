class AddColumnsToReferenceBooks < ActiveRecord::Migration[6.0]
  def change
    add_column :reference_books, :page_url, :string
    add_column :reference_books, :image_url, :string
  end
end
