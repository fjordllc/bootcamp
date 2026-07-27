class RemoveIndexUserIdFromFootprints < ActiveRecord::Migration[8.1]
  def change
    remove_index :footprints, :user_id, name: "index_footprints_on_user_id"
  end
end
