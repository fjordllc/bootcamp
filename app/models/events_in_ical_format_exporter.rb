# frozen_string_literal: true

class EventsInIcalFormatExporter
  def self.export_events(events)
    cal = Icalendar::Calendar.new
    events.each do |event|
      tzid = 'Asia/Tokyo'

      cal.event do |e|
        e.dtstart     = Icalendar::Values::DateTime.new event.start_at, { 'tzid' => tzid }
        e.dtend       = Icalendar::Values::DateTime.new event.end_at, { 'tzid' => tzid }
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
