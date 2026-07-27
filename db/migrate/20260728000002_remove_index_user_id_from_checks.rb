class RemoveIndexUserIdFromChecks < ActiveRecord::Migration[8.1]
  def change
    remove_index :checks, :user_id, name: "index_checks_on_user_id"
  end
end
