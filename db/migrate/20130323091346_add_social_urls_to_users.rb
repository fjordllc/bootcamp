# frozen_string_literal: true

class AddSocialUrlsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :twitter_url, :string
    add_column :users, :facebook_url, :string
    add_column :users, :blog_url, :string
  end
end
