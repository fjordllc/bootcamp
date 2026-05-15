# frozen_string_literal: true

class TimesChannelCreator
  def call(_name, _started, _finished, _unique_id, payload)
    user = payload[:user]
    raise ArgumentError, "#{user.login_name}は現役生または研修生ではありません。" unless user.student_or_trainee?

    times_channel = Discord::TimesChannel.new(user.login_name)
    if times_channel.save
      times_url = "https://discord.com/channels/#{ENV['DISCORD_GUILD_ID']}/#{times_channel.id}"
      user.discord_profile.update(times_id: times_channel.id, times_url:)
    else
      Rails.logger.warn "[Discord API] #{user.login_name}の分報チャンネルが作成できませんでした。"
    end
  end
end
