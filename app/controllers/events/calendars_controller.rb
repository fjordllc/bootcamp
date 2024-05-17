# frozen_string_literal: true

class Events::CalendarsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: :index

  def index
    user_id = params[:user_id]
    user = User.find_by(id: user_id)

    calendar = Calendar.new
    subscription_calendar =  calendar.combined_calendar(user).publish
    render plain: subscription_calendar.to_ical
  end
end
