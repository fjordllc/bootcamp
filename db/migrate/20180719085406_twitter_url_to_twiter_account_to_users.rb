class TwitterUrlToTwiterAccountToUsers < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :twitter_url, :twitter_account
  end
end
