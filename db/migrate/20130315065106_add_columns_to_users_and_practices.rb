class AddColumnsToUsersAndPractices < ActiveRecord::Migration
  def change
    add_column :practices, :aim_cd, :integer, null: false, default: 0
    add_column :users,     :major_cd, :integer
  end
end
