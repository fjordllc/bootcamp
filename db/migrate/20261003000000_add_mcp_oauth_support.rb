# frozen_string_literal: true

class AddMcpOauthSupport < ActiveRecord::Migration[8.1]
  def change
    add_column :oauth_applications, :mcp_client, :boolean, default: false, null: false
    change_table :oauth_access_grants, bulk: true do |table|
      table.text :resource
      table.string :code_challenge
      table.string :code_challenge_method
    end

    add_column :oauth_access_tokens, :resource, :text
  end
end
