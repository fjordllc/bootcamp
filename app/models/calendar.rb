# frozen_string_literal: true

class Calendar
  def initialize(user)
    @user = user
    @fetched_events = EventsFetcher.new(@user)
  end

  def combine_special_regular_calendar
    formatted_calendar_to_ical = generate_formatted_calendar
    formatted_regular_calendar_to_ical = generate_formatted_regular_calendar

    formatted_calendar_to_ical = "#{formatted_calendar_to_ical}#{formatted_regular_calendar_to_ical}"
    Icalendar::Calendar.parse(formatted_calendar_to_ical).first
  end

  private

  def generate_formatted_calendar
    personal_events = @fetched_events.fetch_events
    events_to_icalendar = EventsToIcalConverter.new
    converted_calendar = events_to_icalendar.convert_events_to_ical(personal_events)

    calendar_to_ical = converted_calendar.to_ical
    calendar_to_ical.gsub(/END:VCALENDAR\r?\n?\z/, '')
  end

  def generate_formatted_regular_calendar
    personal_regular_events = @fetched_events.fetch_regular_events
    regular_events_to_icalendar = EventsToIcalConverter.new
    converted_regular_calendar = regular_events_to_icalendar.convert_regular_events_to_ical(personal_regular_events)

    regular_calendar_to_ical = converted_regular_calendar.to_ical
    regular_calendar_to_ical.gsub(/\A(?:BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:icalendar-ruby\r\nCALSCALE:GREGORIAN\r\n)/, '')
  end
end
