# frozen_string_literal: true

DAYS_OF_THE_WEEK_COUNT = 7

module RegularEventDecorator
  def holding_cycles
    repeat_rules.map do |repeat_rule|
      holding_frequency = RegularEvent::FREQUENCY_LIST.find { |frequency| frequency[1] == repeat_rule[:frequency] }[0]
      holding_day_of_the_week = RegularEvent::DAY_OF_THE_WEEK_LIST.find { |day_of_the_week| day_of_the_week[1] == repeat_rule[:day_of_the_week] }[0]
      holding_frequency + holding_day_of_the_week
    end.join(',')
  end

  def next_event_date
    "次回の開催日は #{l possible_next_event_dates.compact.min} です"
  end

  def repeat_rules
    regular_event_repeat_rules.map do |repeat_rule|
      { frequency: repeat_rule.frequency, day_of_the_week: repeat_rule.day_of_the_week }
    end
  end

  def possible_next_event_dates
    today = Time.zone.today
    this_month_first_day = Date.new(today.year, today.mon, 1)
    next_month_first_day = this_month_first_day.next_month

    canditates = repeat_rules.map do |repeat_rule|
      [
        possible_next_event_date(this_month_first_day, repeat_rule),
        possible_next_event_date(next_month_first_day, repeat_rule)
      ]
    end.flatten
    canditates.compact.select { |canditate| canditate > Time.zone.today }.sort
  end

  def possible_next_event_date(first_day, repeat_rule)
    if (repeat_rule[:frequency]).zero?
      next_specific_day_of_the_week(repeat_rule) if Time.zone.today.mon == first_day.mon
    else
      date = (repeat_rule[:frequency] - 1) * DAYS_OF_THE_WEEK_COUNT + repeat_rule[:day_of_the_week] - first_day.wday + 1
      date += DAYS_OF_THE_WEEK_COUNT if repeat_rule[:day_of_the_week] < first_day.wday
      Date.new(first_day.year, first_day.mon, date)
    end
  end

  def next_specific_day_of_the_week(repeat_rule)
    case repeat_rule[:day_of_the_week]
    when 0
      0.days.ago.next_occurring(:sunday).to_date
    when 1
      0.days.ago.next_occurring(:monday).to_date
    when 2
      0.days.ago.next_occurring(:tuesday).to_date
    when 3
      0.days.ago.next_occurring(:wednesday).to_date
    when 4
      0.days.ago.next_occurring(:thursday).to_date
    when 5
      0.days.ago.next_occurring(:friday).to_date
    when 6
      0.days.ago.next_occurring(:saturday).to_date
    end
  end
end
