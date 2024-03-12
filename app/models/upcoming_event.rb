# frozen_string_literal: true

class UpcomingEvent
  class << self
    def fetch(*day_symbols)
      day_symbols.map do |day|
        {
          day_label: day,
          events: fetch_events_held_on(day),
          holding_date: calc_holding_date(day)
        }
      end
    end

    private

    def fetch_events_held_on(day)
      method_name = "#{day}_events".to_sym
      events = Event.public_send(method_name) + RegularEvent.public_send(method_name)
      events.sort_by { |e| e.start_at.strftime('%H:%M') }
    end

    def calc_holding_date(day)
      case day
      when :today
        Time.zone.today
      when :tomorrow
        Time.zone.tomorrow
      when :day_after_tomorrow
        Time.zone.tomorrow + 1.day
      end
    end
  end
end
