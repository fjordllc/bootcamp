# frozen_string_literal: true

class AddMentorToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :mentor, :boolean, null: false, default: false
  end
end
