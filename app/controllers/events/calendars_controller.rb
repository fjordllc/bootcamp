# frozen_string_literal: true

class Events::CalendarsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: :index

  def index
    user_id = params[:user_id]
    user = User.find_by(id: user_id)

    events_calendar = EventsCalendar.new(user)
    @events = events_calendar.generate_event_calendar

    render :index, layout: false, content_type: 'text/calendar'
  end
end
