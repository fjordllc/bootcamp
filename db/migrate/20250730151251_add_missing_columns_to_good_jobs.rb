class AddMissingColumnsToGoodJobs < ActiveRecord::Migration[7.2]
  def change
    add_column :good_jobs, :is_discrete, :boolean
    add_column :good_jobs, :executions_count, :integer
    add_column :good_jobs, :labels, :text, array: true
    add_column :good_jobs, :locked_by_id, :uuid
    add_column :good_jobs, :locked_at, :datetime
  end
end
