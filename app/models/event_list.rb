# frozen_string_literal: true

class EventList
  def fetch_events_list(user)
    participated_list = user.participations.pluck(:event_id)
    upcoming_event_list = Event.where('start_at > ?', Date.current).pluck(:id)

    joined_events = Event.where(id: participated_list & upcoming_event_list)
    upcoming_events = Event.where(id: upcoming_event_list).where.not(id: participated_list)
    {
      joined_events:,
      upcoming_events:
    }
  end

  def fetch_regular_events_list(user)
    participated_list = user.regular_event_participations.pluck(:regular_event_id)
    regular_events_list = []
    RegularEvent.where(id: participated_list).where(finished: false).find_each do |event|
      event.regular_event_repeat_rules.each do |repeat_rule|
        current_date = Time.zone.today

        list_regular_event_for_year(event, repeat_rule, current_date, regular_events_list)
      end
    end
    regular_events_list
  end

  private

  def list_regular_event_for_year(event,  repeat_rule, current_date, regular_events_list)
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
      regular_events_list << { event_id: event.id, event_date: }
    end
  end
end
