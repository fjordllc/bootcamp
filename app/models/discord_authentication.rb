# frozen_string_literal: true

class DiscordAuthentication
  include Rails.application.routes.url_helpers

  def initialize(login_user, auth)
    @login_user = login_user
    @auth = auth
  end

  def authenticate
    if link
      { path: root_path, notice: 'Discordと連携しました' }
    else
      { path: root_path, alert: 'Discordの連携に失敗しました' }
    end
  end

  private

  def link
    discord_profile = DiscordProfile.find_or_initialize_by(user: @login_user)
    discord_profile.account_name = @auth.info.name
    discord_profile.save
  end
end
