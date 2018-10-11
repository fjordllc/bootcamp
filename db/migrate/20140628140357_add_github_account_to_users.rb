# frozen_string_literal: true

class AddGithubAccountToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :github_account, :string
  end
end
