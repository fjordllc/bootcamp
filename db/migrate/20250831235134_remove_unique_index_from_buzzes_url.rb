class RemoveUniqueIndexFromBuzzesUrl < ActiveRecord::Migration[6.1]
  def change
    remove_index :buzzes, :url
  end
end
