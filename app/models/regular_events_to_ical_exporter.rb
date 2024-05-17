# frozen_string_literal: true

class RegularEventsToIcalExporter
  def export_events(user)
    holding_events = fetch_events(user)
    cal = Icalendar::Calendar.new

    holding_events.each do |holding_event|
      tzid = 'Asia/Tokyo'
      event_date = Date.parse(holding_event[:event_date].to_s)
      event = RegularEvent.find(holding_event[:event_id])

      cal.event do |e|
        e.dtstart = Icalendar::Values::DateTime.new(
          DateTime.parse("#{event_date} #{event.start_at.strftime('%H:%M')}"), 'tzid' => tzid
        )
        e.dtend = Icalendar::Values::DateTime.new(
          DateTime.parse("#{event_date} #{event.end_at.strftime('%H:%M')}"), 'tzid' => tzid
        )
        e.summary     = event.title
        e.description = event.description
        e.uid         = "event#{event.id}#{event_date}"
        e.sequence    = Time.now.to_i
      end
    end
    cal
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
