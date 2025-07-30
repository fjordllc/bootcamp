class AddMissingIndexesToGoodJobs < ActiveRecord::Migration[7.2]
  def change
    add_index :good_jobs, [:priority, :scheduled_at], order: { priority: "ASC NULLS LAST", scheduled_at: :asc },
      where: "finished_at IS NULL AND locked_by_id IS NULL", name: :index_good_jobs_on_priority_scheduled_at_unfinished_unlocked
    add_index :good_jobs, :locked_by_id,
      where: "locked_by_id IS NOT NULL", name: "index_good_jobs_on_locked_by_id"
    add_index :good_jobs, :labels, using: :gin, where: "(labels IS NOT NULL)", name: :index_good_jobs_on_labels
    add_index :good_jobs, [:priority, :created_at], order: { priority: "ASC NULLS LAST", created_at: :asc },
      where: "finished_at IS NULL", name: :index_good_job_jobs_for_candidate_lookup
  end
end
