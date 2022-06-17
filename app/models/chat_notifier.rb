# frozen_string_literal: true

class ChatNotifier
  def self.message(
    message,
    username: 'ピヨルド',
    webhook_url: 'https://discordapp.com/api/webhooks/987204651801792584/oKZkNcevfH_94Vbs6-aZZ9XZD9IlCGvrqGgsjV6W1p9zynHLIQDYQSfiobDnKnVYguNx'
  )

    if Rails.env.development?
      Discord::Notifier.message(message, username: username, url: webhook_url)
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

    if Rails.env.production?
      Discord::Notifier.message(embed, url: webhook_url)
    else
      Rails.logger.info 'Notify to Discord.'
    end
  end
end
