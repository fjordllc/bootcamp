class RemoveIndexUserIdFromRegularEventParticipations < ActiveRecord::Migration[8.1]
  def change
    remove_index :regular_event_participations, :user_id, name: "index_regular_event_participations_on_user_id"
  end
end
