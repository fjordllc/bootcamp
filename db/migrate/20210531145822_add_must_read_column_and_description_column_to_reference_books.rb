class AddMustReadColumnAndDescriptionColumnToReferenceBooks < ActiveRecord::Migration[6.1]
  def change
    add_column :reference_books, :must_read, :boolean, default: false, null: false
    add_column :reference_books, :description, :text
  end
end
