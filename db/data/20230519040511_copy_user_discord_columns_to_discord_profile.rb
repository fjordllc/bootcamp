# frozen_string_literal: true

class CopyUserDiscordColumnsToDiscordProfile < ActiveRecord::Migration[6.1]
  def up
    User.all.each do |user|
      discord_profile = user.build_discord_profile
      discord_profile.account_name = user.discord_account unless user.discord_account.nil?
      discord_profile.times_url = user.times_url unless user.times_url.nil?
      discord_profile.times_id = user.times_id unless user.times_id.nil?
      discord_profile.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
