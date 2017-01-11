class ChangeAdviserToDefaultFalseInUsers < ActiveRecord::Migration[4.2]
  def change
    change_column :users, :adviser, :boolean, null: false, default: false
  end
end
