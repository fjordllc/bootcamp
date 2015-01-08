class ChangeAdviserToDefaultFalseInUsers < ActiveRecord::Migration
  def change
    change_column :users, :adviser, :boolean, null: false, default: false
  end
end
