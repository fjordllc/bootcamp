class AddFeedUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :feed_url, :string
  end
end
