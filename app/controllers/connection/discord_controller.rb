# frozen_string_literal: true

class Connection::DiscordController < ApplicationController
  skip_before_action :require_active_user_login, raise: false

  def destroy
    current_user.discord_profile.update(account_name: nil)
    redirect_to root_path, notice: 'Discordとの連携を解除しました。'
  end
end
