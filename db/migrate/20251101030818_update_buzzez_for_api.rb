class UpdateBuzzezForAPI < ActiveRecord::Migration[6.1]
  def change
    remove_column :buzzes, :body, :text

    add_column :buzzes, :url, :string, null: false
    add_column :buzzes, :title, :string, null: false
    add_column :buzzes, :published_at, :date, null: false
    add_column :buzzes, :memo, :text

    add_index :buzzes, :url, unique: true
  end
end
