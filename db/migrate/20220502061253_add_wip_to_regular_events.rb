class AddWipToRegularEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :regular_events, :wip, :boolean, null: false, default: false
  end
end
