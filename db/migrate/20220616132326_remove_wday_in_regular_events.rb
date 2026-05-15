class RemoveWdayInRegularEvents < ActiveRecord::Migration[6.1]
  def change
    remove_column :regular_events, :wday, :string
  end
end
