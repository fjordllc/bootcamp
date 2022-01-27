class AddIndexUserIdAndStatusToLearnings < ActiveRecord::Migration[6.1]
  def change
    add_index :learnings, [:user_id, :status]
  end
end
