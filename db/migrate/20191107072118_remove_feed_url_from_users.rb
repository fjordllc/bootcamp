# frozen_string_literal: true

class RemoveFeedUrlFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :feed_url, :string
  end
end
