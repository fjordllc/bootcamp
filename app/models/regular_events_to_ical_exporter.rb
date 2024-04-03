# frozen_string_literal: true

class RegularEventsToIcalExporter
  def self.export_events(holding_events)
    cal = Icalendar::Calendar.new

    holding_events.each do |holding_event|
      tzid = 'Asia/Tokyo'
      event_date = Date.parse(holding_event[:event_date].to_s)
      event = RegularEvent.find(holding_event[:event_id])

      cal.event do |e|
        e.dtstart     = Icalendar::Values::DateTime.new(
          DateTime.parse("#{event_date} #{event.start_at.strftime('%H:%M')}"),'tzid' => tzid)
        e.dtend       = Icalendar::Values::DateTime.new(
          DateTime.parse("#{event_date} #{event.end_at.strftime('%H:%M')}"),'tzid' => tzid)
        e.summary     = event.title
        e.description = event.description
        e.uid         = "event#{event.id}#{event_date}"
        e.sequence    = Time.now.to_i
      end
    end
    cal
  end
end
