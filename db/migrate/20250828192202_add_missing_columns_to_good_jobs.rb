class AddMissingColumnsToGoodJobs < ActiveRecord::Migration[7.2]
  def change
    # Add missing columns for GoodJob 4.x
    add_column :good_jobs, :is_discrete, :boolean
    add_column :good_jobs, :executions_count, :integer
    add_column :good_jobs, :job_class, :text
    add_column :good_jobs, :error_event, :integer, limit: 2
    add_column :good_jobs, :labels, :text, array: true
    add_column :good_jobs, :locked_by_id, :uuid
    add_column :good_jobs, :locked_at, :datetime
  end
end
