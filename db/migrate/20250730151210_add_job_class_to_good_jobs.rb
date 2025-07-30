class AddJobClassToGoodJobs < ActiveRecord::Migration[7.2]
  def change
    add_column :good_jobs, :job_class, :text
  end
end
