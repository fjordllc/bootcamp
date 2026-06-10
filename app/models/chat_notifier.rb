# frozen_string_literal: true

class ChatNotifier
  def self.message(
    message,
    username: 'ピヨルド',
    webhook_url: ENV['DISCORD_NOTICE_WEBHOOK_URL']
  )
    return log_missing_webhook_url if webhook_url.blank?

    if Rails.env.production?
      Discord::Notifier.message(message, username:, url: webhook_url)
    else
      Rails.logger.info 'Message to Discord.'
    end
  end

  def self.notify(
    title:,
    title_url:,
    description:,
    user:,
    webhook_url: ENV['DISCORD_NOTICE_WEBHOOK_URL']
  )
    user_url = Rails.application.routes.url_helpers.user_url(
      user,
      host: 'bootcamp.fjord.jp',
      protocol: 'https'
    )

    author = { name: user.login_name, url: user_url, icon_url: user.avatar_url }

    embed = Discord::Embed.new do
      title title
      url title_url
      description description
      author author
      color '4638a0'
    end

    return log_missing_webhook_url if webhook_url.blank?

    if Rails.env.production?
      Discord::Notifier.message(embed, url: webhook_url)
    else
      Rails.logger.info 'Notify to Discord.'
    end
  end

  def self.log_missing_webhook_url
    Rails.logger.warn 'Discord webhook URL is not configured.'
  end
  private_class_method :log_missing_webhook_url
end
