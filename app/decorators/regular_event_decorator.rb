# frozen_string_literal: true

module RegularEventDecorator
  def holding_cycles
    regular_event_repeat_rules.map do |repeat_rule|
      holding_frequency = RegularEvent::FREQUENCY_LIST.find { |frequency| frequency[1] == repeat_rule.frequency }[0]
      holding_day_of_the_week = RegularEvent::DAY_OF_THE_WEEK_LIST.find { |day_of_the_week| day_of_the_week[1] == repeat_rule.day_of_the_week }[0]
      holding_frequency + holding_day_of_the_week
    end.join(',')
  end

  def next_holding_date
    return '開催終了' if finished
    return '本日開催' if event_day?

    "次回の開催日は #{l next_event_date} です"
  end
end
