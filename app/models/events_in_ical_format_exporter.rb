# frozen_string_literal: true

class EventsInIcalFormatExporter
  def self.export_events(events)
    cal = Icalendar::Calendar.new
    cal.event do |e|
      events.each do |event|
        e.dtstart     = event.start_at
        e.dtend       = event.end_at
        e.summary     = event.title
        e.description = event.description
        e.location    = event.location
      end
    end
    cal
  end
end
