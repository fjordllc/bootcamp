# frozen_string_literal: true

class AddColumnGitHubIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :github_id, :string, index: true, unique: true
  end
end
