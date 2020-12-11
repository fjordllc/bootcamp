# frozen_string_literal: true

class AddIndexToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users do |t|
      t.index :email, unique: true
      t.index :github_id, unique: true
      t.index :login_name, unique: true
    end
  end
end
