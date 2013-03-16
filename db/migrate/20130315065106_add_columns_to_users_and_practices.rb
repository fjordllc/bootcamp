class AddColumnsToUsersAndPractices < ActiveRecord::Migration
  def change
    add_column :practices, :target_cd, :integer, null: false, default: 0
    add_column :users,     :job_cd, :integer
  end
end
