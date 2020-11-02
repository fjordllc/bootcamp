# frozen_string_literal: true

class NoticeSlackJob < ApplicationJob
  queue_as :default

  def perform(text, options = {})
    notify(text, options)
  end

  private
    def notify(text, options = {})
      if Rails.env.production?
        icon_url = options[:icon_url] || "https://i.gyazo.com/7099977680d8d8c2d72a3f14ddf14cc6.png"
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
