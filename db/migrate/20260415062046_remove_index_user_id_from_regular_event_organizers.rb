class RemoveIndexUserIdFromRegularEventOrganizers < ActiveRecord::Migration[8.1]
  def change
    remove_index :regular_event_organizers, :user_id, name: "index_regular_event_organizers_on_user_id"
  end
end
