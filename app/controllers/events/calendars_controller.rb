# frozen_string_literal: true

class Events::CalendarsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: :index

  def index
    user_id = params[:user_id]
    user = User.find_by(id: user_id)

    events_calendar = EventsCalendar.new
    events_calendar.fetch_events(user)

    ical = events_calendar.to_ical

    render plain: events_calendar.to_ical, content_type: 'text/calendar'
  end
end
