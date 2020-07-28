# frozen_string_literal: true

module EventsHelper
  def google_calendar_link(event)
    "http://www.google.com/calendar/render?action=TEMPLATE&text=#{event.title}&dates=#{event.start_at.strftime("%Y%m%dT%H%M%S")}/#{event.end_at.strftime("%Y%m%dT%H%M%S")}&details=https://bootcamp.fjord.jp/events/#{event.id}"
  end
end
