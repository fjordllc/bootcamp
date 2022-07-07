# frozen_string_literal: true

class DiscordNotifier < ApplicationNotifier
  self.driver = DiscordDriver.new
  self.async_adapter = DiscordAsyncAdapter.new

  def graduated(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:admin]

    notification(
      body: "#{params[:sender].login_name}さんが卒業しました。",
      name: 'ピヨルド',
      webhook_url: webhook_url
    )
  end

  def hibernated(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:admin]

    notification(
      body: "#{params[:sender].login_name}さんが休会しました。",
      name: 'ピヨルド',
      webhook_url: webhook_url
    )
  end
end
