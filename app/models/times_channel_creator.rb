# frozen_string_literal: true

class TimesChannelCreator
  def call(user)
    raise ArgumentError, "#{user.login_name}は現役生または研修生ではありません。" unless user.student_or_trainee?

    times_channel = Discord::TimesChannel.new(user.login_name)
    if times_channel.save
      user.update(times_id: times_channel.id)
    else
      Rails.logger.warn "[Discord API] #{user.login_name}の分報チャンネルが作成できませんでした。"
    end
  end
end
