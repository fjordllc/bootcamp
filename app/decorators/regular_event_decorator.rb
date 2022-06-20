# frozen_string_literal: true

MAX_DAYS_OF_NEXT_EVENT_COUNT = 35

module RegularEventDecorator
  def holding_cycles
    repeat_rules = regular_event_repeat_rules.pluck(:frequency, :day_of_the_week)
    repeat_rules.map do |repeat_rule|
      holding_frequency = RegularEvent::FREQUENCY_LIST.find { |frequency| frequency[1] == repeat_rule[0] }[0]
      holding_day_of_the_week = RegularEvent::DAY_OF_THE_WEEK_LIST.find { |day_of_the_week| day_of_the_week[1] == repeat_rule[1] }[0]
      holding_frequency + holding_day_of_the_week
    end.join(',')
  end

  def next_event_date
    "次回の開催日は #{l filtered_canditates_of_next_event_date.compact.min} です"
  end

  def filtered_canditates_of_next_event_date
    repeat_rules = regular_event_repeat_rules.pluck(:frequency, :day_of_the_week)
    today = Time.zone.today
    nth_week_of_month = calc_week_of_month(today)
    canditates_of_next_event_date = (1..MAX_DAYS_OF_NEXT_EVENT_COUNT).map { |n| today + n }

    repeat_rules.map do |repeat_rule|
      if (repeat_rule[0]).zero?
        canditates_of_next_event_date.find { |date| date.wday == repeat_rule[1] }
      else
        canditates_of_next_event_date.find { |date| date.wday == repeat_rule[1] && calc_week_of_month(date) == nth_week_of_month }
      end
    end
  end

  def calc_week_of_month(date)
    first_week_of_this_month = (date - (date.day - 1)).cweek
    this_week = date.cweek

    # 年末年始の対応
    if this_week < first_week_of_this_month
      return calc_week_of_month(date - 7) + 1 if date.month == 12

      return this_week
    end

    this_week - first_week_of_this_month + 1
  end
end
