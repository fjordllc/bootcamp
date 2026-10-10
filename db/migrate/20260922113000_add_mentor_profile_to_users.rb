# frozen_string_literal: true

class AddMentorProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :mentor_profile, :text
  end
end
