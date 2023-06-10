# frozen_string_literal: true

class TimesChannelDestroyer
  def call(user)
    return unless user.times_id

    if Discord::Server.delete_text_channel(user.times_id)
      user.update!(times_id: nil)
    else
      Rails.logger.warn "[Discord API] #{user.login_name}の分報チャンネルが削除できませんでした。"
    end
  end
end
