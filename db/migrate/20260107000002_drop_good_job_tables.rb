# frozen_string_literal: true

class DropGoodJobTables < ActiveRecord::Migration[8.0]
  def up
    drop_table :good_jobs, if_exists: true
    drop_table :good_job_executions, if_exists: true
    drop_table :good_job_processes, if_exists: true
    drop_table :good_job_settings, if_exists: true
    drop_table :good_job_batches, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
