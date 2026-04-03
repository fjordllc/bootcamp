# frozen_string_literal: true

module RegularEventDecorator
  def holding_cycles
    regular_event_repeat_rules.map do |repeat_rule|
      holding_frequency = RegularEvent::FREQUENCY_LIST.find { |frequency| frequency[1] == repeat_rule.frequency }[0]
      holding_day_of_the_week = I18n.t('date.day_names')[repeat_rule.day_of_the_week]
      holding_frequency + holding_day_of_the_week
    end.join('、')
  end

  def next_holding_date
    if finished
      '開催終了'
    elsif next_event_date == Time.zone.today
      '本日開催'
    else
      "次回の開催日は #{l next_event_date} です"
    end
  end

  def upcoming_skip_event_dates(from: Time.zone.today, limit: 5)
    to = from.next_year

    skip_dates = regular_event_skip_dates
                 .where(skip_on: from..to)
                 .pluck(:skip_on, :reason)
                 .map { |date, reason| { date:, reason: } }

    skip_holidays = HolidayJp.between(from, to)
                             .filter_map do |holiday|
                               { date: holiday.date, reason: "祝日(#{holiday.name})のため" } if date_match_the_rules?(holiday.date, regular_event_repeat_rules)
    end

    (skip_dates + skip_holidays)
      .sort_by { |h| h[:date] }
      .first(limit)
  end
end
