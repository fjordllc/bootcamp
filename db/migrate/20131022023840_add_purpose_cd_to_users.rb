class AddPurposeCdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :purpose_cd, :integer, default: 0, null: false
  end
end
