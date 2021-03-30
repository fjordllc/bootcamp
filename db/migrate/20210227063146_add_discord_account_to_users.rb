# frozen_string_literal: true

class AddDiscordAccountToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :discord_account, :string
  end
end
