# frozen_string_literal: true

class Events::CalendarsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: :index

  def index
    user_id = params[:user_id]
    user = User.find_by(id: user_id)

    calendar = EventSubscription.combined_calendar(user)
    calendar.publish
    render plain: calendar.to_ical
  end
end
