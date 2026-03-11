# frozen_string_literal: true

module RegularEventDecorator
  def holding_cycles
    regular_event_repeat_rules.map do |repeat_rule|
      holding_frequency = RegularEvent::FREQUENCY_LIST.find { |frequency| frequency[1] == repeat_rule.frequency }[0]
      holding_day_of_the_week = RegularEvent::DAY_OF_THE_WEEK_LIST.find { |day_of_the_week| day_of_the_week[1] == repeat_rule.day_of_the_week }[0]
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

  def upcoming_closed_days(today: Time.zone.today)
    from = today
    to = from.next_year

    scheduled_dates = all_scheduled_dates(from:, to:)
    skip_reasons = regular_event_skip_dates.where(skip_on: from..to).pluck(:skip_on, :reason).to_h

    scheduled_dates
      .filter_map do |date|
        if skip_reasons.key?(date)
          { date:, reason: skip_reasons[date] }
        elsif skip_holiday?(date)
          { date:, reason: '祝日のため' }
        end
      end
      .take(5)
      .map { |h| "#{l(h[:date], format: :long)} : #{h[:reason]}" }
  end
end
