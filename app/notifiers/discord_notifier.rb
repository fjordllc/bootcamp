# frozen_string_literal: true

class DiscordNotifier < ApplicationNotifier
  self.driver = DiscordDriver.new
  self.async_adapter = DiscordAsyncAdapter.new

  def graduated(params = {})
    params.merge!(@params)

    notification(
      body: "#{params[:sender].login_name}さんが卒業しました。",
      name: 'ピヨルド',
      webhook_url: Rails.application.secrets[:webhook][:admin]
    )
  end
end
