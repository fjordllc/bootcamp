class RemoveUniqueIndexFromBuzzesTitle < ActiveRecord::Migration[6.1]
  def change
    remove_index :buzzes, :title
  end
end
