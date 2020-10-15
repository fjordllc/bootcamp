# frozen_string_literal: true

class CreateFollowings < ActiveRecord::Migration[6.0]
  def change
    create_table :followings do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    add_index :followings, :follower_id
    add_index :followings, :followed_id
    add_index :followings, [:follower_id, :followed_id], unique: true
  end
end
