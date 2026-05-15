class AddTimesIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :times_id, :string, comment: 'Snowflake ID'
  end
end
