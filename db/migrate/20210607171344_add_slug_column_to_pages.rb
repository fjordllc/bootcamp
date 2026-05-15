class AddSlugColumnToPages < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :slug, :string, limit: 200, default: nil
    add_index :pages, :slug, unique: true
  end
end
