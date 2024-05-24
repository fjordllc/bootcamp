# frozen_string_literal: true

class Calendar
  def combine_special_regular_calendar(user)
    calendar_to_ical_str = generate_calendar_str(user)
    regular_calendar_to_ical_str = generate_regular_calendar_str(user)

    calendar_to_ical_str = "#{calendar_to_ical_str}#{regular_calendar_to_ical_str}"
    Icalendar::Calendar.parse(calendar_to_ical_str).first
  end

  private

  def generate_calendar_str(user)
    events_list = EventList.new
    personal_events_list = events_list.fetch_events_list(user)
    events_icalendar_str = IcalendarStr.new
    calendar_str = events_icalendar_str.convert_events_to_ical(personal_events_list)

    calendar_to_ical = calendar_str.to_ical
    calendar_to_ical.gsub(/END:VCALENDAR\r?\n?\z/, '')
  end

  def generate_regular_calendar_str(user)
    regular_events_list = EventList.new
    personal_regular_events_list = regular_events_list.fetch_regular_events_list(user)
    regular_events_icalendar_str = IcalendarStr.new
    regular_calendar_str = regular_events_icalendar_str.convert_regular_events_to_ical(personal_regular_events_list)

    regular_calendar_to_ical = regular_calendar_str.to_ical
    regular_calendar_to_ical.gsub(/\A(?:BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:icalendar-ruby\r\nCALSCALE:GREGORIAN\r\n)/, '')
  end
end
