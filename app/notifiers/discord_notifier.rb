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
    webhook_url = params[:webhook_url] || Rails.application.config_for(:secrets)[:webhook][:admin]

    notification(
      body: "#{params[:sender].login_name}さんが休会しました。",
      name: 'ピヨルド',
      webhook_url:
    )
  end

  def announced(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.config_for(:secrets)[:webhook][:all]

    path = Rails.application.routes.url_helpers.polymorphic_path(params[:announce])
    url = "https://bootcamp.fjord.jp#{path}"

    notification(
      body: "お知らせ：「#{params[:announce].title}」\r<#{url}>",
      name: 'ピヨルド',
      webhook_url:
    )
  end

  def coming_soon_regular_events(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.config_for(:secrets)[:webhook][:all]
    today_events = params[:today_events].sort_by { |event| event.start_at.strftime('%H%M') }
    tomorrow_events = params[:tomorrow_events].sort_by { |event| event.start_at.strftime('%H%M') }
    today = Time.current
    tomorrow = Time.current.next_day
    event_info = <<~TEXT.gsub(/^\n+/, "\n").chomp
      ⚡️⚡️⚡️イベントのお知らせ⚡️⚡️⚡️

      #{add_event_info(today_events, '今日', today)}

      #{'------------------------------' if today_events.present?}

      #{add_event_info(tomorrow_events, '明日', tomorrow)}

      ⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️
    TEXT

    notification(
      body: event_info,
      name: 'ピヨルド',
      webhook_url:
    )
  end

  def add_event_info(events, date_message, date)
    event_info = events.present? ? "< #{date_message} (#{I18n.l(date, format: :mdw)}) 開催 >\n\n" : ''
    not_held_events, held_events = events.partition do |event|
      event.skip_event?(date)
    end
    held_events.each do |event|
      event_info += "#{event.title}\n"
      event_info += "時間: #{event.start_at.strftime('%H:%M')}〜#{event.end_at.strftime('%H:%M')}\n"
      event_info += "詳細: <#{Rails.application.routes.url_helpers.regular_event_url(event)}>\n\n"
    end
    not_held_events.each do |event|
      event_info += "⚠️ #{event.title}\n"
    end
    event_info += "はお休みです。\n\n" if not_held_events.present?
    event_info
  end

  def invalid_user(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.config_for(:secrets)[:webhook][:admin]
    body = params[:body].slice(0, 2000) # Discord API restriction

    notification(
      body:,
      name: 'ピヨルド',
      webhook_url:
    )
  end

  def payment_failed(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.config_for(:secrets)[:webhook][:admin]

    notification(
      body: params[:body],
      name: 'ピヨルド',
      webhook_url:
    )
  end

  def product_review_not_completed(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.config_for(:secrets)[:webhook][:mentor]

    comment = params[:comment]
    product_checker_name = comment.commentable.checker.discord_profile&.account_name
    product_checker_discord_id = Discord::Server.find_member_id(member_name: product_checker_name)
    product_checker_discord_name = "<@#{product_checker_discord_id}>"
    product = comment.commentable

    body = <<~TEXT.chomp
      ⚠️ #{comment.user.login_name}さんの「#{comment.commentable.practice.title}」の提出物が、最後のコメントから3日経過しました。
      担当：#{product_checker_discord_name}さん
      URL： <#{Rails.application.routes.url_helpers.product_url(product)}>
    TEXT

    notification(
      body:,
      name: 'ピヨルド',
      webhook_url:
    )
  end

  def first_report(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.config_for(:secrets)[:webhook][:introduction]
    report = params[:report]
    body = <<~TEXT.chomp
      🎉 #{report.user.login_name}さんがはじめての日報を書きました！
      タイトル：「#{report.title}」
      URL： <#{Rails.application.routes.url_helpers.report_url(report)}>
    TEXT

    notification(
      body:,
      name: 'ピヨルド',
      webhook_url:
    )
  end
end
