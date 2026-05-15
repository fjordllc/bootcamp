class ChangeOrganizersToRegularEventOrganizer < ActiveRecord::Migration[8.1]
  def change
    rename_table :organizers, :regular_event_organizers
  end
end
