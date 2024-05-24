# frozen_string_literal: true

class IcalendarStr
  def convert_events_to_ical(events_list)
    event_cal = Icalendar::Calendar.new

    events_list[:joined_events].each do |event|
      add_event_to_calendar(event_cal, event, true)
    end

    events_list[:upcoming_events].each do |event|
      add_event_to_calendar(event_cal, event, false)
    end
    event_cal
  end

  def convert_regular_events_to_ical(regular_events_list)
    regular_event_cal = Icalendar::Calendar.new

    add_regular_event_to_calendar(regular_event_cal, regular_events_list)
    regular_event_cal
  end

  private

  def add_event_to_calendar(event_cal, event, joined)
    tzid = 'Asia/Tokyo'
    event_cal.event do |e|
      e.dtstart     = Icalendar::Values::DateTime.new event.start_at, { 'tzid' => tzid }
      e.dtend       = Icalendar::Values::DateTime.new event.end_at, { 'tzid' => tzid }
      e.summary     = joined ? "【参加登録済】#{event.title}" : event.title
      e.description = event.description
      e.location    = event.location
      e.uid         = "event#{event.id}"
      e.sequence    = Time.now.to_i
    end
  end

  def add_regular_event_to_calendar(regular_event_cal, regular_events_list)
    regular_events_list.each do |regular_event|
      tzid = 'Asia/Tokyo'
      event_date = Date.parse(regular_event[:event_date].to_s)
      event = RegularEvent.find(regular_event[:event_id])

      regular_event_cal.event do |e|
        e.dtstart = Icalendar::Values::DateTime.new(
          DateTime.parse("#{event_date} #{event.start_at.strftime('%H:%M')}"), 'tzid' => tzid
        )
        e.dtend = Icalendar::Values::DateTime.new(
          DateTime.parse("#{event_date} #{event.end_at.strftime('%H:%M')}"), 'tzid' => tzid
        )
        e.summary     = event.title
        e.description = event.description
        e.uid         = "event#{event.id}#{event_date}"
        e.sequence    = Time.now.to_i
      end
    end
  end
end
