class AddTaskColumnsToTaskRequests < ActiveRecord::Migration[5.1]
  def self.up
    add_attachment :submissions, :task
  end

  def self.down
    remove_attachment :submissions, :task
  end
end
