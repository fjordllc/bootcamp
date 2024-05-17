# frozen_string_literal: true

class Calendar
  def combined_calendar(user)
    special_calendar = special_calendar_str(user)
    regular_calendar = regular_calendar_str(user)

    calendar_str = "#{special_calendar}#{regular_calendar}"
    Icalendar::Calendar.parse(calendar_str).first
  end

  private

  def special_calendar_str(user)
    special_calendar = EventsToIcalExporter.new
    special_calendar_to_ical = special_calendar.export_events(user).to_ical
    special_calendar_to_ical.gsub(/END:VCALENDAR\r?\n?\z/, '')
  end

  def regular_calendar_str(user)
    regular_calendar = RegularEventsToIcalExporter.new
    regular_calendar_to_ical = regular_calendar.export_events(user).to_ical
    regular_calendar_to_ical.gsub(/\A(?:BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:icalendar-ruby\r\nCALSCALE:GREGORIAN\r\n)/, '')
  end
end
