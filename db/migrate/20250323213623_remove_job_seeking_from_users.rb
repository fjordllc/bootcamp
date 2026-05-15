class RemoveJobSeekingFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :job_seeking, :boolean
  end
end
