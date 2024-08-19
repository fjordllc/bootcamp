# frozen_string_literal: true

class EventsCalendar
  def initialize
    @events = []
  end

  def fetch_events(user)
    upcoming_special_events = UpcomingEvent.fetch(user)

    participated_regular_events = RegularEvent.fetch_participated_regular_events(user)

    @events = upcoming_special_events + participated_regular_events
  end

  def to_ical
    cal = Icalendar::Calendar.new

    @events.each do |event|
      tzid = 'Asia/Tokyo'

      cal.event do |e|
        e.dtstart     = Icalendar::Values::DateTime.new event_time(event, :start), { 'tzid' => tzid }
        e.dtend       = Icalendar::Values::DateTime.new event_time(event, :end), { 'tzid' => tzid }
        e.summary     = event.title
        e.description = event.description
        e.location    = event.respond_to?(:location) && event.location.present? ? event.location : nil
        e.uid         = event.id.to_s
      end
    end

    cal.publish
    cal.to_ical
  end

  private

  def event_time(event, start_or_end)
    if start_or_end == :start
      event.is_a?(RegularEvent) ? event.start_on : event.start_at
    else
      event.is_a?(RegularEvent) ? event.end_on : event.end_at
    end
  end
end
