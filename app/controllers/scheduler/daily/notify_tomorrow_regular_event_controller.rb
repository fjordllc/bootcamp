# frozen_string_literal: true

class Scheduler::Daily::NotifyTomorrowRegularEventController < ApplicationController
  def show
    notify_tomorrow_regular_event
    head :ok
  end

  private

  def notify_tomorrow_regular_event
    return if RegularEvent.tomorrow_events.blank?

    tomorrow_events = RegularEvent.tomorrow_events

    day_of_the_week = %w[日 月 火 水 木 金 土]
    event_date = tomorrow_events.first.next_event_date
    event_info = '--------------------------------------------'

    tomorrow_events.each do |event|
      event_info += <<~TEXT.chomp

        #{event.title}
        時間: #{event.start_at.strftime('%H:%M')} 〜 #{event.end_at.strftime('%H:%M')}
        詳細: #{Rails.application.routes.url_helpers.regular_event_url(event)}
        --------------------------------------------
      TEXT
    end

    message = <<~TEXT.chomp
      ⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️
      【イベントのお知らせ】
      明日 #{event_date.strftime("%m月%d日（#{day_of_the_week[event_date.wday]}）")}に開催されるイベントです！
      #{event_info}
      ⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️
    TEXT

    DiscordNotifier.with(body: message).tomorrow_regular_event.notify_now
  end
end
