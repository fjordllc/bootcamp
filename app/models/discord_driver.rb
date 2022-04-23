# frozen_string_literal: true

class DiscordDriver
  def call(params)
    Discord::Notifier.message(
      params[:body],
      username: params[:name],
      url: params[:webhook_url]
    )
  end
end
