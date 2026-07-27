class RemoveIndexUserIdFromProducts < ActiveRecord::Migration[8.1]
  def change
    remove_index :products, :user_id, name: "index_products_on_user_id"
  end
end
