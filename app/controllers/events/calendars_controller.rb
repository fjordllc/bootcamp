# frozen_string_literal: true

class Events::CalendarsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: :index

  def index
    user = User.find_by(id: params[:user_id])

    unless user
      head :not_found
      return
    end

    events_calendar = EventsCalendar.new
    events_calendar.fetch_events(user)

    render plain: events_calendar.to_ical, content_type: 'text/calendar'
  end
end
