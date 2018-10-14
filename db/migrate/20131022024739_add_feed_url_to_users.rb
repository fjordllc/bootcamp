# frozen_string_literal: true

class AddFeedUrlToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :feed_url, :string
  end
end
