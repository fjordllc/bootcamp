# frozen_string_literal: true

class RemoveFeedUrlFromUsers < ActiveRecord::Migration[5.2]
  def up
    remove_column :users, :feed_url
  end

  def down
    add_column :users, :feed_url, :string
  end
end
