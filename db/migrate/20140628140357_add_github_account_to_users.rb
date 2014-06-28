class AddGithubAccountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :github_account, :string
  end
end
