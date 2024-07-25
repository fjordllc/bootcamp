# frozen_string_literal: true

class EventsCalendar
  def initialize
    @events = []
  end

  def fetch_events(user)
    upcoming_special_events = Event.fetch_upcoming_events(user)

    participated_regular_events = RegularEvent.fetch_participated_regular_events(user)

    @events = upcoming_special_events + participated_regular_events
  end

  def to_ical
    cal = Icalendar::Calendar.new

    @events.each do |event|
      cal.event do |e|
        e.dtstart     = Icalendar::Values::DateTime.new(event.start_at)
        e.dtend       = Icalendar::Values::DateTime.new(event.end_at)
        e.summary     = event.title
        e.description = event.description
        e.location    = event.respond_to?(:location) && event.location.present? ? event.location : nil
        e.uid         = event.id.to_s
      end
    end

    cal.publish
    cal.to_ical
  end
end
