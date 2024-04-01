# frozen_string_literal: true

class Events::CalendarsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: :index

  def index
    user_id = params[:user_id]
    user = User.find_by(id: user_id)

    respond_to do |format|
      format.ics do
        calendar = EventsToIcalExporter.export_events(set_export(user))
        calendar.publish
        render plain: calendar.to_ical
      end
    end
  end

  private

  def set_export(user)
    participated_list = user.participations.pluck(:event_id)
    upcoming_event_list = Event.where('start_at > ?', Date.current).pluck(:id)

    joined_events = Event.where(id: participated_list & upcoming_event_list)
    upcoming_events = Event.where(id: upcoming_event_list).where.not(id: participated_list)
    {
      joined_events: joined_events,
      upcoming_events: upcoming_events
    }
  end
end
