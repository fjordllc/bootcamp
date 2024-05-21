# frozen_string_literal: true

module EventDateGatherer
  class << self
    def all_scheduled_dates(event)
      return event.start_at.to_date if event.instance_of?(Event)

      rules = event.regular_event_repeat_rules
      from = Date.new(Time.current.year, 1, 1)
      to = Date.new(Time.current.year, 12, 31)

      (from..to).select { |d| match_wday_of_rules?(d, rules) }
    end

    private

    def match_wday_of_rules?(date, rules)
      rules.any? do |rule|
        if rule.frequency.zero?
          rule.day_of_the_week == date.wday
        else
          rule.frequency == calc_what_weeks(date) && rule.day_of_the_week == date.wday
        end
      end
    end

    def calc_what_weeks(date)
      (date.day + 6) / 7
    end
  end
end
