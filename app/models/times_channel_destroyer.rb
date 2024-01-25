# frozen_string_literal: true

class TimesChannelDestroyer
  def call(payload)
    user = payload[:user]
    return unless user.discord_profile.times_id

    if Discord::Server.delete_text_channel(user.discord_profile.times_id)
      user.discord_profile.update!(times_id: nil)
    else
      Rails.logger.warn "[Discord API] #{user.login_name}の分報チャンネルが削除できませんでした。"
    end
  end
end
