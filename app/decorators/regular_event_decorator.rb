# frozen_string_literal: true

MAX_DAYS_OF_NEXT_EVENT_COUNT = 35

module RegularEventDecorator
  def holding_cycles
    repeat_rules.map do |repeat_rule|
      holding_frequency = RegularEvent::FREQUENCY_LIST.find { |frequency| frequency[1] == repeat_rule[:frequency] }[0]
      holding_day_of_the_week = RegularEvent::DAY_OF_THE_WEEK_LIST.find { |day_of_the_week| day_of_the_week[1] == repeat_rule[:day_of_the_week] }[0]
      holding_frequency + holding_day_of_the_week
    end.join(',')
  end

  def next_event_date
    "次回の開催日は #{l filtered_canditates_of_next_event_date.compact.min} です"
  end

  def filtered_canditates_of_next_event_date
    repeat_rules.map do |repeat_rule|
      if (repeat_rule[:frequency]).zero?
        canditates_of_next_event_date.find { |date| date.wday == repeat_rule[:day_of_the_week] }
      else
        canditate_of_next_event_date_with_frequency(repeat_rule)
      end
    end
  end

  def repeat_rules
    regular_event_repeat_rules.map do |repeat_rule|
      { frequency: repeat_rule.frequency, day_of_the_week: repeat_rule.day_of_the_week }
    end
  end

  def canditates_of_next_event_date
    today = Time.zone.today
    (1..MAX_DAYS_OF_NEXT_EVENT_COUNT).map { |n| today + n }
  end

  def canditate_of_next_event_date_with_frequency(repeat_rule)
    canditate = canditates_of_next_event_date.find { |date| date.wday == repeat_rule[:day_of_the_week] && calc_week_of_month(date) == repeat_rule[:frequency] }

    if canditate.nil?
      canditates_of_next_event_date.find { |date| date.wday == repeat_rule[:day_of_the_week] && calc_week_of_month(date) == repeat_rule[:frequency] + 1 }
    else
      canditate
    end
  end

  def calc_week_of_month(date)
    first_week = (date - (date.day - 1)).cweek
    this_week = date.cweek

    # 年末年始の対応
    if this_week < first_week
      return calc_week_of_month(date - 7) + 1 if date.month == 12

      return this_week
    end

    # 月始まりで2週目にカウントされないようにする
    return 1 if date.day <= 7

    this_week - first_week + 1
  end
end
