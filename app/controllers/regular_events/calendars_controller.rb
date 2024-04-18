# frozen_string_literal: true

class RegularEvents::CalendarsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: :index

  def index
    user_id = params[:user_id]
    user = User.find_by(id: user_id)

    regular_calendar = RegularEventsToIcalExporter.export_events(fetch_events(user))
    render plain: regular_calendar.to_ical
  end

  private

  def fetch_events(user)
    participated_list = user.regular_event_participations.pluck(:regular_event_id)
    holding_events = []
    RegularEvent.where(id: participated_list).where(finished: false).find_each do |event|
      event.regular_event_repeat_rules.each do |repeat_rule|
        current_date = Time.zone.today

        while current_date <= Time.zone.today + 1.year
          if repeat_rule.frequency.zero?
            day_of_the_week_symbol = DateAndTime::Calculations::DAYS_INTO_WEEK.key(repeat_rule.day_of_the_week)
            event_date = current_date.next_occurring(day_of_the_week_symbol).to_date
            event_date = event_date.next_occurring(day_of_the_week_symbol) while !event.hold_national_holiday && HolidayJp.holiday?(event_date)
            current_date = event_date + 1
          else
            event_date = event.possible_next_event_date(current_date, repeat_rule)
            current_date = current_date.next_month.beginning_of_month
          end
          holding_events << { event_id: event.id, event_date: }
        end
      end
    end
    holding_events
  end
end
