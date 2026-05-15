class RemoveDiscordAccountAndTimesUrlAndTimesIdFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :discord_account, :string
    remove_column :users, :times_url, :string
    remove_column :users, :times_id, :string
  end
end
