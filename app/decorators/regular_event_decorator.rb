# frozen_string_literal: true

module RegularEventDecorator
  def holding_cycles
    repeat_rules = regular_event_repeat_rules.pluck(:frequency, :day_of_the_week)
    repeat_rules.map do |repeat_rule|
      holding_frequency = RegularEvent::FREQUENCY_LIST.find { |frequency| frequency[1] == repeat_rule[0] }[0]
      holding_day_of_the_week = RegularEvent::DAY_OF_THE_WEEK_LIST.find { |day_of_the_week| day_of_the_week[1] == repeat_rule[1] }[0]
      holding_frequency + holding_day_of_the_week
    end.join(',')
  end
end
