# frozen_string_literal: true

class UpcomingEvent
  %i[today tomorrow day_after_tomorrow].each do |day|
    method_name = "#{day}_events"
    define_singleton_method(method_name) do
      (Event.public_send(method_name) + RegularEvent.public_send(method_name)).sort_by { |e| e.start_at.strftime('%H:%M') }
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
