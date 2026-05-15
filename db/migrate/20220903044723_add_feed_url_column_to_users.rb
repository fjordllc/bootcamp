class AddFeedUrlColumnToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :feed_url, :string
  end
end
