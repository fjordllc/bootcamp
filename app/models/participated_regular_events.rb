# frozen_string_literal: true

class ParticipatedRegularEvents
  def initialize(regular_event)
    @regular_event = regular_event
  end

  def list_event_for_year(repeat_rule, current_date, participated_regular_events)
    while current_date <= Time.zone.today + 1.year
      if repeat_rule.frequency.zero?
        day_of_the_week_symbol = DateAndTime::Calculations::DAYS_INTO_WEEK.key(repeat_rule.day_of_the_week)
        event_date = current_date.next_occurring(day_of_the_week_symbol).to_date
        event_date = event_date.next_occurring(day_of_the_week_symbol) while !@regular_event.hold_national_holiday && HolidayJp.holiday?(event_date)
        current_date = event_date + 1
      else
        event_date = @regular_event.possible_next_event_date(current_date, repeat_rule)
        current_date = current_date.next_month.beginning_of_month
      end
      participated_regular_events << format_event_date(event_date)
    end
  end

  def format_event_date(event_date)
    event = @regular_event.dup
    tzid = 'Asia/Tokyo'

    event.assign_attributes(
      start_at: Icalendar::Values::DateTime.new(
        DateTime.parse("#{event_date} #{event.start_at.strftime('%H:%M')}"), 'tzid' => tzid
      ),
      end_at: Icalendar::Values::DateTime.new(
        DateTime.parse("#{event_date} #{event.end_at.strftime('%H:%M')}"), 'tzid' => tzid
      )
    )
    event
  end
end
