# frozen_string_literal: true

class Events::CalendarsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: :index

  def index
    user_id = params[:user_id]
    user = User.find_by(id: user_id)

    events_calendar = EventsCalendar.new(user)
    events_calendar.fetch_events
    @events = events_calendar.events

    render :index, layout: false, content_type: 'text/calendar'
  end
end
