# frozen_string_literal: true

class EventsInIcalFormatExporter
  def self.export_events(events)
    cal = Icalendar::Calendar.new
    events.each do |event|
      cal.event do |e|
        e.dtstart     = event.start_at
        e.dtend       = event.end_at
        e.summary     = event.title
        e.description = event.description
        e.location    = event.location
        e.uid         = "event#{event.id}"
        e.sequence    = Time.now.to_i
      end
    end
    cal
  end
end
