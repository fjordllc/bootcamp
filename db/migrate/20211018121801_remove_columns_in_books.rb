class RemoveColumnsInBooks < ActiveRecord::Migration[6.1]
  def change
    remove_reference :books, :practice, index: true, foreign_key: true
    remove_column :books, :must_read, :boolean
  end
end
