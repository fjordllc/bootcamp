# frozen_string_literal: true

class AddLockTypeToGoodJobProcesses < ActiveRecord::Migration[7.2]
  def change
    return unless table_exists?(:good_job_processes)
    return if column_exists?(:good_job_processes, :lock_type)

    add_column :good_job_processes, :lock_type, :integer, limit: 2
  end
end
