# frozen_string_literal: true

class TimesChannelDestroyer
  def call(name, _started, _finished, _id, payload)
    user = payload[:user]
    return unless user.discord_profile.times_id

    if delete_text_channel(name, user)
      user.discord_profile.times_id = nil
      user.discord_profile.times_url = nil
      user.discord_profile.save!(context: :retirement)
    else
      Rails.logger.warn "[Discord API] #{user.login_name}の分報チャンネルが削除できませんでした。"
    end
  end

  private

  def delete_text_channel(event, user)
    Discord::Server.delete_text_channel(user.discord_profile.times_id)
  rescue Discordrb::Errors::NoPermission => e
    raise unless event == 'retirement.create'

    Rollbar.error(
      e,
      event:,
      user_id: user.id,
      channel_id: user.discord_profile.times_id,
      recovery_action: 'botの権限を修正し、残存チャンネルを削除してください。両方の対応が完了してからRollbarを解決済みにしてください。'
    )
    nil
  end
end
