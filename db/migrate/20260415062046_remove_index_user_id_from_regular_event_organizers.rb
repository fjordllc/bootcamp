class RemoveIndexUserIdFromRegularEventOrganizers < ActiveRecord::Migration[8.1]
  def change
    remove_index :regular_event_organizers, column: :user_id, name: "index_regular_event_organizers_on_user_id", if_exists: true
  end
end
