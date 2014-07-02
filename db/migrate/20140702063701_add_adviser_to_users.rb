class AddAdviserToUsers < ActiveRecord::Migration
  def change
    add_column :users, :adviser, :boolean, default: false, null: false
  end
end
