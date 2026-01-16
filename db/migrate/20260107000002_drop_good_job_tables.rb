# frozen_string_literal: true

class DropGoodJobTables < ActiveRecord::Migration[7.2]
  def change
    drop_table :good_job_batches if table_exists?(:good_job_batches)
    drop_table :good_job_executions if table_exists?(:good_job_executions)
    drop_table :good_job_processes if table_exists?(:good_job_processes)
    drop_table :good_job_settings if table_exists?(:good_job_settings)
    drop_table :good_jobs if table_exists?(:good_jobs)
  end
end
