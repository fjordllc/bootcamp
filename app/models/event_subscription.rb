# frozen_string_literal: true

class EventSubscription
  def self.combined_calendar(user)
    special_calendar = special_calendar_str(user)
    regular_calendar = regular_calendar_str(user)

    calendar_str = "#{special_calendar}#{regular_calendar}"
    Icalendar::Calendar.parse(calendar_str).first
  end

  def self.special_calendar_str(user)
    special_calendar = EventsToIcalExporter.export_events(user)
    special_calendar_to_ical = special_calendar.to_ical
    special_calendar_to_ical.gsub(/END:VCALENDAR\r?\n?\z/, '')
  end

  def self.regular_calendar_str(user)
    regular_calendar = RegularEventsToIcalExporter.export_events(user)
    regular_calendar_to_ical = regular_calendar.to_ical
    regular_calendar_to_ical.gsub(/\A(?:BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:icalendar-ruby\r\nCALSCALE:GREGORIAN\r\n)/, '')
  end
end
