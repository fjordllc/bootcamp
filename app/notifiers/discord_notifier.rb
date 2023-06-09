# frozen_string_literal: true

class DiscordNotifier < ApplicationNotifier # rubocop:disable Metrics/ClassLength
  self.driver = DiscordDriver.new
  self.async_adapter = DiscordAsyncAdapter.new

  def graduated(params = {})
    params.merge!(@params)

    notification(
      body: "#{params[:sender].login_name}さんが卒業しました。",
      name: 'ピヨルド',
      webhook_url: params[:webhook_url]
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
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:all]
    day_of_the_week = %w[日 月 火 水 木 金 土]
    event_date = event.next_event_date
    event_info = <<~TEXT.chomp
      ⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️
      【イベントのお知らせ】
      明日 #{event_date.strftime("%m月%d日（#{day_of_the_week[event_date.wday]}）")}に開催されるイベントです！
      --------------------------------------------
      #{event.title}
      時間: #{event.start_at.strftime('%H:%M')} 〜 #{event.end_at.strftime('%H:%M')}
      詳細: #{Rails.application.routes.url_helpers.regular_event_url(event)}
      --------------------------------------------
      ⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️
    TEXT

    notification(
      body: event_info,
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

  def payment_failed(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:admin]

    notification(
      body: params[:body],
      name: 'ピヨルド',
      webhook_url: webhook_url
    )
  end

  def product_review_not_completed(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:mentor]
    comment = params[:comment]
    product_checker_name = comment.commentable.checker_name
    product = comment.commentable
    body = <<~TEXT.chomp
      ⚠️ #{comment.user.login_name}さんの「#{comment.commentable.practice.title}」の提出物が、最後のコメントから5日経過しました。
      担当：#{product_checker_name}さん
      URL： #{Rails.application.routes.url_helpers.product_url(product)}
    TEXT

    notification(
      body: body,
      name: 'ピヨルド',
      webhook_url: webhook_url
    )
  end

  def first_report(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:introduction]
    report = params[:report]
    body = <<~TEXT.chomp
      🎉 #{report.user.login_name}さんがはじめての日報を書きました！
      タイトル：「#{report.title}」
      URL： #{Rails.application.routes.url_helpers.report_url(report)}
    TEXT

    notification(
      body: body,
      name: 'ピヨルド',
      webhook_url: webhook_url
    )
  end
end
