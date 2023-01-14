# frozen_string_literal: true

class DiscordDriver
  def call(params)
    if params[:webhook_url]
      Discord::Notifier.message(
        params[:body],
        username: params[:name],
        url: params[:webhook_url]
      )
    elsif params[:admin_webhook_url] && params[:mentor_webhook_url]
      webhook_urls = [params[:admin_webhook_url], params[:mentor_webhook_url]]
      webhook_urls.each do |url|
        Discord::Notifier.message(
          params[:body],
          username: params[:name],
          url: url
        )
      end
    end
  end
end
