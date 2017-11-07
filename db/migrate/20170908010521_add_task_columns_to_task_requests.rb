class AddTaskColumnsToTaskRequests < ActiveRecord::Migration[5.1]
  def self.up
    add_attachment :task_requests, :task
  end

  def self.down
    remove_attachment :task_requests, :task
  end
end
