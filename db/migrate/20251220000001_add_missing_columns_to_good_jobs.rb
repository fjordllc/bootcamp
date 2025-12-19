# frozen_string_literal: true

class AddMissingColumnsToGoodJobs < ActiveRecord::Migration[7.2]
  def change
    # Add missing columns to good_jobs table if they don't exist
    add_column :good_jobs, :error_event, :integer, limit: 2 unless column_exists?(:good_jobs, :error_event)
    add_column :good_jobs, :labels, :text, array: true unless column_exists?(:good_jobs, :labels)
    add_column :good_jobs, :locked_by_id, :uuid unless column_exists?(:good_jobs, :locked_by_id)
    add_column :good_jobs, :locked_at, :datetime unless column_exists?(:good_jobs, :locked_at)
    add_column :good_jobs, :is_discrete, :boolean unless column_exists?(:good_jobs, :is_discrete)
    add_column :good_jobs, :executions_count, :integer unless column_exists?(:good_jobs, :executions_count)
    add_column :good_jobs, :job_class, :text unless column_exists?(:good_jobs, :job_class)
    add_column :good_jobs, :batch_id, :uuid unless column_exists?(:good_jobs, :batch_id)
    add_column :good_jobs, :batch_callback_id, :uuid unless column_exists?(:good_jobs, :batch_callback_id)

    # Add missing indexes
    unless index_exists?(:good_jobs, :labels, name: 'index_good_jobs_on_labels')
      add_index :good_jobs, :labels, using: :gin, where: "(labels IS NOT NULL)", name: :index_good_jobs_on_labels
    end

    unless index_exists?(:good_jobs, :locked_by_id, name: 'index_good_jobs_on_locked_by_id')
      add_index :good_jobs, :locked_by_id, where: "locked_by_id IS NOT NULL", name: "index_good_jobs_on_locked_by_id"
    end

    unless index_exists?(:good_jobs, :batch_id, name: 'index_good_jobs_on_batch_id')
      add_index :good_jobs, [:batch_id], where: "batch_id IS NOT NULL", name: 'index_good_jobs_on_batch_id'
    end

    unless index_exists?(:good_jobs, :batch_callback_id, name: 'index_good_jobs_on_batch_callback_id')
      add_index :good_jobs, [:batch_callback_id], where: "batch_callback_id IS NOT NULL", name: 'index_good_jobs_on_batch_callback_id'
    end

    unless index_exists?(:good_jobs, :job_class, name: 'index_good_jobs_on_job_class')
      add_index :good_jobs, :job_class, name: :index_good_jobs_on_job_class
    end

    unless index_exists?(:good_jobs, [:priority, :scheduled_at], name: 'index_good_jobs_on_priority_scheduled_at_unfinished_unlocked')
      add_index :good_jobs, [:priority, :scheduled_at], order: { priority: "ASC NULLS LAST", scheduled_at: :asc },
        where: "finished_at IS NULL AND locked_by_id IS NULL", name: :index_good_jobs_on_priority_scheduled_at_unfinished_unlocked
    end
  end
end
