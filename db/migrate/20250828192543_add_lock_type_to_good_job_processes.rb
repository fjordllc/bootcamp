class AddLockTypeToGoodJobProcesses < ActiveRecord::Migration[7.2]
  def change
    add_column :good_job_processes, :lock_type, :integer, limit: 2
  end
end
