# frozen_string_literal: true

class DiscordAuthenticationsController < ApplicationController
  def new
    redirect_uri = discord_authentications_new_url
    access_token = DiscordAuthentication.fetch_access_token(params[:code], redirect_uri)
    discord_account_name = DiscordAuthentication.fetch_discord_account_name(access_token)

    discord_profile = DiscordProfile.find_or_initialize_by(user: current_user)
    discord_profile.account_name = discord_account_name

    if discord_profile.save
      redirect_to root_path, notice: 'Discordと連携しました'
    else
      redirect_to root_path, alert: 'Discordの連携に失敗しました'
    end
  end
end
