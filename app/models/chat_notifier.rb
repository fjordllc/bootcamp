# frozen_string_literal: true

class ChatNotifier
  def self.notify(
    title:,
    title_url:,
    description:,
    user:,
    webhook_url:
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
