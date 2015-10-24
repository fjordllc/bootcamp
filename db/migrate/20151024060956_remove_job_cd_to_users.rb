class RemoveJobCdToUsers < ActiveRecord::Migration
  def change
    remove_column :users, :job_cd, :string
  end
end
