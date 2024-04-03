# frozen_string_literal: true


class RegularEvents::CalendarsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: :index

  def index
    user_id = params[:user_id]
    user = User.find_by(id: user_id)
    respond_to do |format|
      format.ics do
        calendar = RegularEventsToIcalExporter.export_events(set_export(user))
        calendar.publish
        render plain: calendar.to_ical
      end
    end
  end

  private

  def set_export(user)
    participated_list = user.regular_event_participations.pluck(:regular_event_id)
    
      holding_events = []
      RegularEvent.where(id: participated_list).where(finished: false).each do |event|
        event.regular_event_repeat_rules.each do |repeat_rule|
          current_date = Date.today
          days_of_the_week_count = 7
    
          while current_date <= Date.today + 3.month do
            if repeat_rule.frequency.zero?
              day_of_the_week_symbol = DateAndTime::Calculations::DAYS_INTO_WEEK.key(repeat_rule.day_of_the_week)
              event_date = current_date.next_occurring(day_of_the_week_symbol).to_date
              event_date = event_date.next_occurring(day_of_the_week_symbol) while !event.hold_national_holiday && HolidayJp.holiday?(event_date)
              holding_events << { event_id: event.id, event_date: event_date }
              current_date =  event_date + 1
            else
              event_date = event.possible_next_event_date(current_date, repeat_rule)
              holding_events << { event_id: event.id, event_date: event_date }
              current_date = current_date.next_month.beginning_of_month
            end  
          end
        end
      end
      holding_events
  end
end
