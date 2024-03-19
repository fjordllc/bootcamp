# frozen_string_literal: true

class UpcomingEvent
  # define class method ".today_events", "tomorrow_events", "day_after_tomorrow_events"
  %i[today tomorrow day_after_tomorrow].each do |day|
    method = "#{day}_events"
    define_singleton_method(method) do
      (Event.public_send(method) + RegularEvent.public_send(method)).sort_by { |e| e.start_at.strftime('%H:%M') }
    end
  end

  class << self
    def fetch(*day_symbols)
      day_symbols.map do |day|
        {
          date_label: day,
          events: public_send("#{day}_events"),
          event_date: convert_to_date(day)
        }
      end
    end

    private

    def convert_to_date(day)
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
