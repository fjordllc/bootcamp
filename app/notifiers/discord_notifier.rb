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

  def coming_soon_regular_events(params = {})
    params.merge!(@params)
    webhook_url = params[:webhook_url] || Rails.application.secrets[:webhook][:all]
    today_events = params[:today_events] || RegularEvent.today_events
    tomorrow_events = params[:tomorrow_events] || RegularEvent.tomorrow_events
    today = Time.current.ago(27.days)
    tomorrow = Time.current.ago(27.days).next_day
    event_info = "⚡️⚡️⚡️イベントのお知らせ⚡️⚡️⚡️\n\n"
    event_info = add_event_info(today_events, '今日', today, event_info)
    event_info += "------------------------------\n\n" if today_events.present?
    event_info = add_event_info(tomorrow_events, '明日', tomorrow, event_info)
    event_info += '⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️'

    notification(
      body: event_info,
      name: 'ピヨルド',
      webhook_url: 'https://discord.com/api/webhooks/1111511603813306409/LFqYGRq9JypvLYdzXucLr-5EPa1k6j4PL8yLtslqHGWJbGA1-CJur60UAPu2ExeIVxut'
    )
  end

  def add_event_info(events, date_message, date, event_info)
    day_of_the_week = %w[日 月 火 水 木 金 土]
    event_info += "< #{date_message} (#{date.strftime('%m/%d')} #{day_of_the_week[date.wday]} 開催 >\n\n" if events.present?
    held_events, not_held_events = separate_held_events(events,date)
    held_events.each do |event|
      event_info += "#{event.title}\n"
      event_info += "時間: #{event.start_at.strftime('%H:%M')}〜#{event.end_at.strftime('%H:%M')}\n"
      event_info += "詳細: #{Rails.application.routes.url_helpers.regular_event_url(event)}\n\n"
    end
    # event_info += "~~~ \n\n" if not_held_events.present?
    not_held_events.each do |event|
      event_info += "⚠️　#{event.title}\n"
    end
    event_info += "はお休みです。\n\n" if not_held_events.present?
    event_info
  end

  def separate_held_events(events,date)
    held_events = []
    not_held_events = []
    events.each do |event|
      if HolidayJp.holiday?(date) && !event.hold_national_holiday
        not_held_events.push(event)
      else
        held_events.push(event)
      end
    end
    [held_events, not_held_events]
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
    product_checker_name = User.find_by(id: comment.commentable.checker_id).login_name
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
