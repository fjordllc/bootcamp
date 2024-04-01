# frozen_string_literal: true

class EventsToIcalExporter
  def self.export_events(events_set)
    cal = Icalendar::Calendar.new

    events_set[:joined_events].each do |event|
      add_event_to_calendar(cal, event, true)
    end
  
    events_set[:upcoming_events].each do |event|
      add_event_to_calendar(cal, event, false)
    end
    cal
  end

  private

  def self.add_event_to_calendar(cal, event, joined)
    tzid = 'Asia/Tokyo'
    cal.event do |e|
      e.dtstart     = Icalendar::Values::DateTime.new event.start_at, { 'tzid' => tzid }
      e.dtend       = Icalendar::Values::DateTime.new event.end_at, { 'tzid' => tzid }
      e.summary     = joined ? "【参加登録済】#{event.title}" : event.title
      e.description = event.description
      e.location    = event.location
      e.uid         = "event#{event.id}"
      e.sequence    = Time.now.to_i
    end
  end
end
