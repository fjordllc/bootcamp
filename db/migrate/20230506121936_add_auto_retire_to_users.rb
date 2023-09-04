class AddAutoRetireToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :auto_retire, :boolean, default: true
  end
end
