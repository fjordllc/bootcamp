# frozen_string_literal: true

module EventSchedule
  class RegularEventSchedule
    def initialize(event)
      @event = event
      @rules = @event.regular_event_repeat_rules
    end

    def tentative_next_event_date
      from, to = init_period

      scheduled_dates = gather_scheduled_dates(@rules, from:, to:)
      scheduled_dates.min
    end

    def held_next_event_date
      from, to = init_period

      tenantive_dates = gather_scheduled_dates(@rules, from:, to:)

      held_dates =
        @event.hold_national_holiday ? tenantive_dates : tenantive_dates.reject { |date| HolidayJp.holiday?(date) }
      held_dates.min
    end

    private

    def init_period
      from = Time.current
      to = from.next_month.end_of_month
      [from, to]
    end

    def gather_scheduled_dates(rules, from:, to:)
      # イテレートするために変換が必要
      from_date = from.to_date
      to_date = to.to_date
      dates_matched_rules = (from_date..to_date).select { |date| match_rules?(date, rules) }

      hour = @event.start_at.hour
      min = @event.start_at.min
      dates_with_start_time = dates_matched_rules.map { |date| give_start_at_time(date, hour:, min:) }

      dates_with_start_time.reject { |date| date < from }
    end

    def match_rules?(date, rules)
      rules.any? do |rule|
        rule.day_of_the_week == date.wday if rule.frequency.zero?
      end
    end

    def give_start_at_time(date, hour:, min:)
      date.in_time_zone.change(hour:, min:)
    end
  end
end
