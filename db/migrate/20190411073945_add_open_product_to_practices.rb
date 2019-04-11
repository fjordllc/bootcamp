class AddOpenProductToPractices < ActiveRecord::Migration[5.2]
  def change
    add_column :practices, :open_product, :boolean, default: false, null: false
  end
end
