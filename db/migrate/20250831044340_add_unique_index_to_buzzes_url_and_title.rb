class AddUniqueIndexToBuzzesUrlAndTitle < ActiveRecord::Migration[6.1]
  def change
    add_index :buzzes, :url, unique: true
    add_index :buzzes, :title, unique: true
  end
end
