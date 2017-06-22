class AddWishToStartOnToContacts < ActiveRecord::Migration[5.0]
  def change
    add_column :contacts, :wish_to_start_on, :date
  end
end
