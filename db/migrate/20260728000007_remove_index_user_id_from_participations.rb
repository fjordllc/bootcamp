class RemoveIndexUserIdFromParticipations < ActiveRecord::Migration[8.1]
  def change
    remove_index :participations, :user_id, name: "index_participations_on_user_id"
  end
end
