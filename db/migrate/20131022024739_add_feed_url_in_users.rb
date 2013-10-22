class AddFeedUrlInUsers < ActiveRecord::Migration
  def change
    add_column :users, :feed_url, :string
  end
end
