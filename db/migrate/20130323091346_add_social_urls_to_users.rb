# frozen_string_literal: true

class AddSocialUrlsToUsers < ActiveRecord::Migration[4.2]
  def change
    change_table :users, bulk: true do |t|
      t.string :twitter_url
      t.string :facebook_url
      t.string :blog_url
    end
  end
end
