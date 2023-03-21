# frozen_string_literal: true

class Events::CalendarsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: :index

  def index
    respond_to do |format|
      format.ics do
        calendar = EventsInIcalFormatExporter.export_events(set_export)

        calendar.publish
        render plain: calendar.to_ical
      end
    end
  end

  private

  def set_export
    Event.where('start_at > ?', Time.zone.today)
  end
end
