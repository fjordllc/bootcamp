# frozen_string_literal: true

class DiscordAuthenticationsController < ApplicationController
  def callback
    auth = request.env['omniauth.auth']

    discord_profile = DiscordProfile.find_or_initialize_by(user: current_user)
    discord_profile.account_name = auth.info.name

    if discord_profile.save
      redirect_to root_path, notice: 'Discordと連携しました'
    else
      redirect_to root_path, alert: 'Discordの連携に失敗しました'
    end
  end
end
