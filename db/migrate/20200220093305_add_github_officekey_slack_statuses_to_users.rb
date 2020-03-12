# frozen_string_literal: true

class AddGithubOfficekeySlackStatusesToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :slack_participation, :boolean, null: false, default: true
    add_column :users, :github_collaborator, :boolean,  null: false, default: false
    add_column :users, :officekey_permission, :boolean,  null: false, default: false
  end
end
