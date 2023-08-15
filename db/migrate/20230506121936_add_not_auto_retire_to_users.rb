class AddNotAutoRetireToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :not_auto_retire, :boolean, default: false
  end
end
