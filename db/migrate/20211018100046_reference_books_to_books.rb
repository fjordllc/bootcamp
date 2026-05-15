class ReferenceBooksToBooks < ActiveRecord::Migration[6.1]
  def change
    rename_table :reference_books, :books
  end
end
