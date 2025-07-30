class AddErrorEventToGoodJobs < ActiveRecord::Migration[7.2]
  def change
    add_column :good_jobs, :error_event, :integer
  end
end
