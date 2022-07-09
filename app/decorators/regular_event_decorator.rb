# frozen_string_literal: true

module RegularEventDecorator
  DAYS_OF_THE_WEEK_COUNT = 7

  FREQUENCY_LIST = [
    ['毎週', 0],
    ['第1', 1],
    ['第2', 2],
    ['第3', 3],
    ['第4', 4],
    ['第5', 5]
  ].freeze

  DAY_OF_THE_WEEK_LIST = [
    ['日曜日', 0],
    ['月曜日', 1],
    ['火曜日', 2],
    ['水曜日', 3],
    ['木曜日', 4],
    ['金曜日', 5],
    ['土曜日', 6]
  ].freeze

  def holding_cycles
    regular_event_repeat_rules.map do |repeat_rule|
      holding_frequency = FREQUENCY_LIST.find { |frequency| frequency[1] == repeat_rule.frequency }[0]
      holding_day_of_the_week = DAY_OF_THE_WEEK_LIST.find { |day_of_the_week| day_of_the_week[1] == repeat_rule.day_of_the_week }[0]
      holding_frequency + holding_day_of_the_week
    end.join(',')
  end

  def next_event_date
    return '開催終了' if finished
    return '本日開催' if event_day?

    "次回の開催日は #{l possible_next_event_dates.compact.min} です"
  end

  def event_day?
    now = Time.zone.now
    is_the_day_of_the_event = regular_event_repeat_rules.map do |repeat_rule|
      if repeat_rule.frequency.zero?
        repeat_rule.day_of_the_week == now.wday
      else
        repeat_rule.day_of_the_week == now.wday && repeat_rule.frequency == calc_week_of_month(now)
      end
    end.include?(true)
    event_start_time = Time.zone.local(now.year, now.month, now.day, start_at.hour, start_at.min, 0)

    is_the_day_of_the_event && (now < event_start_time)
  end

  def possible_next_event_dates
    today = Time.zone.today
    this_month_first_day = Date.new(today.year, today.mon, 1)
    next_month_first_day = this_month_first_day.next_month

    canditates = regular_event_repeat_rules.map do |repeat_rule|
      [
        possible_next_event_date(this_month_first_day, repeat_rule),
        possible_next_event_date(next_month_first_day, repeat_rule)
      ]
    end.flatten
    canditates.compact.select { |canditate| canditate > Time.zone.today }.sort
  end

  def possible_next_event_date(first_day, repeat_rule)
    if repeat_rule.frequency.zero?
      next_specific_day_of_the_week(repeat_rule) if Time.zone.today.mon == first_day.mon
    else
      # 次の第n X曜日の日付を計算する
      date = (repeat_rule.frequency - 1) * DAYS_OF_THE_WEEK_COUNT + repeat_rule.day_of_the_week - first_day.wday + 1
      date += DAYS_OF_THE_WEEK_COUNT if repeat_rule.day_of_the_week < first_day.wday
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
