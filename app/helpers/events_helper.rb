# frozen_string_literal: true

module EventsHelper
  def google_calendar_url(event)
    uri = URI('http://www.google.com/calendar/render')
    uri.query =
      {
        action: 'TEMPLATE',
        text: event.title,
        dates: "#{event.start_at.strftime('%Y%m%dT%H%M%S')}/#{event.end_at.strftime('%Y%m%dT%H%M%S')}",
        details: "https://bootcamp.fjord.jp/events/#{event.id}"
      }.to_param
    uri.to_s
  end
end
