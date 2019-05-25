# frozen_string_literal: true

class SlackNotification
  def self.notify(text, options = {})
    if Rails.env.production?
      icon_url = options[:icon_url] || "http://i.gyazo.com/a8afa9d690ff4bbd87459709bbfe8be9.png"
      attachments = options[:attachments] || [{}]
      username = options[:username] || "Bootcamp"
      channel = options[:channel] || "learning_notification"

      notifier = Slack::Notifier.new ENV["SLACK_WEBHOOK_URL"], username: username
      notifier.ping text, icon_url: icon_url, attachments: attachments, channel: channel
    else
      Rails.logger.info "Notify\ntext:#{text}\nparams:#{options}"
    end
  end
end
