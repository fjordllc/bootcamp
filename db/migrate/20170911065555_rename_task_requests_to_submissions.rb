class RenameTaskRequestsToSubmissions < ActiveRecord::Migration[5.1]
  def change
    rename_table :task_requests, :submissions
  end
end
