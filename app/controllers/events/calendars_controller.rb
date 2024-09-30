# frozen_string_literal: true

class Events::CalendarsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: :index
  # ステージング環境での動作確認のため追加、確認後削除予定
  skip_before_action :basic_auth, if: :staging?

  def index
    user_id = params[:user_id]
    user = User.find_by(id: user_id)

    events_calendar = EventsCalendar.new
    events_calendar.fetch_events(user)

    render plain: events_calendar.to_ical, content_type: 'text/calendar'
  end
end
