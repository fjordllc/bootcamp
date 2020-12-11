# frozen_string_literal: true

class AddGithubOfficekeySlackStatusesToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.boolean :slack_participation, null: false, default: true
      t.boolean :github_collaborator, null: false, default: false
      t.boolean :officekey_permission, null: false, default: false
    end
  end
end
