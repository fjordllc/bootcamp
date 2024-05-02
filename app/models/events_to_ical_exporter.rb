# frozen_string_literal: true

class EventsToIcalExporter
  def self.export_events(user)
    events_set = fetch_events(user)
    cal = Icalendar::Calendar.new

    events_set[:joined_events].each do |event|
      add_event_to_calendar(cal, event, true)
    end

    events_set[:upcoming_events].each do |event|
      add_event_to_calendar(cal, event, false)
    end
    cal
  end

  def self.fetch_events(user)
    participated_list = user.participations.pluck(:event_id)
    upcoming_event_list = Event.where('start_at > ?', Date.current).pluck(:id)

    joined_events = Event.where(id: participated_list & upcoming_event_list)
    upcoming_events = Event.where(id: upcoming_event_list).where.not(id: participated_list)
    {
      joined_events:,
      upcoming_events:
    }
  end

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
