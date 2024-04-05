# frozen_string_literal: true

class Events::CalendarsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: :index

  def index
    user_id = params[:user_id]
    user = User.find_by(id: user_id)

    respond_to do |format|
      format.ics do
        special_calendar = EventsToIcalExporter.export_events(fetch_events(user))
        special_calendar_to_ical = special_calendar.to_ical
        special_calendar_str = special_calendar_to_ical.gsub(/END:VCALENDAR\r?\n?\z/, '')
        regular_calendar_to_ical = RestClient.get("#{regular_events_calendars_url}.ics", params: { user_id: })
        regular_calendar_str = regular_calendar_to_ical.gsub(/\A(?:BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:icalendar-ruby\r\nCALSCALE:GREGORIAN\r\n)/, '')
        calendar_str = "#{special_calendar_str}#{regular_calendar_str}"
        calendar = Icalendar::Calendar.parse(calendar_str).first
        calendar.publish
        render plain: calendar.to_ical
      end
    end
  end

  private

  def fetch_events(user)
    participated_list = user.participations.pluck(:event_id)
    upcoming_event_list = Event.where('start_at > ?', Date.current).pluck(:id)

    joined_events = Event.where(id: participated_list & upcoming_event_list)
    upcoming_events = Event.where(id: upcoming_event_list).where.not(id: participated_list)
    {
      joined_events:,
      upcoming_events:
    }
  end
end
