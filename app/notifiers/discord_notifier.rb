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

  def announced(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:all]

    path = Rails.application.routes.url_helpers.polymorphic_path(params[:announce])
    url = "https://bootcamp.fjord.jp#{path}"

    notification(
      body: "お知らせ：「#{params[:announce].title}」\r#{url}",
      name: 'ピヨルド',
      webhook_url: webhook_url
    )
  end

  def tomorrow_regular_event(params = {})
    params.merge!(@params)
    event = params[:event]
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:admin]
    day_of_the_week = %w[日 月 火 水 木 金 土]
    event_date = event.next_event_date

    notification(
      body: "⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️
      【イベントのお知らせ】
      明日 #{event_date.strftime("%m月%d日（#{day_of_the_week[event_date.wday]}）")}に開催されるイベントです！
      --------------------------------------------
      #{event.title}
      時間: #{event.start_at.strftime('%H:%M')} 〜 #{event.end_at.strftime('%H:%M')}
      詳細: #{Rails.application.routes.url_helpers.regular_event_url(event)}
      --------------------------------------------\n⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️",
      name: 'ピヨルド',
      webhook_url: webhook_url
    )
  end

  def invalid_user(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:admin]
    body = params[:body].slice(0, 2000) # Discord API restriction

    notification(
      body: body,
      name: 'ピヨルド',
      webhook_url: webhook_url
    )
  end
end
