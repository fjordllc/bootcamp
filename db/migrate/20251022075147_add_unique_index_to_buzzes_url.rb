class AddUniqueIndexToBuzzesUrl < ActiveRecord::Migration[6.1]
  def change
    add_index :buzzes, :url, unique: true
  end
end
