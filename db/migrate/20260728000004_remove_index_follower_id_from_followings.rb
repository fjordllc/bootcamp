class RemoveIndexFollowerIdFromFollowings < ActiveRecord::Migration[8.1]
  def change
    remove_index :followings, :follower_id, name: "index_followings_on_follower_id"
  end
end
