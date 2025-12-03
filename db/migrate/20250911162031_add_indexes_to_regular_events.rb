class AddIndexesToRegularEvents < ActiveRecord::Migration[7.2]
  def change
    # user_id index already exists
    add_index :regular_events, :start_at
    add_index :regular_events, :end_at
    add_index :regular_events, :finished
  end
end
