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
    elsif holding_today?
      !hold_national_holiday && HolidayJp.holiday?(Time.zone.today) ? "次回の開催日は #{l next_event_date} です" : '本日開催'
    else
      "次回の開催日は #{l next_event_date} です"
    end
  end

  def holding?(date)
    return true unless HolidayJp.holiday?(date)

    hold_national_holiday
  end

  def holiday_schedule_for_year
    today = Time.zone.today

    national_holidays = HolidayJp.between(today, today + 1.year)
    holidays_on_event_dates = national_holidays.select { |holiday| match_event_rules?(holiday.date) }
    formatted_event_holidays = holidays_on_event_dates.map { |date| format_national_holiday(date) }

    formatted_custom_holidays = fetch_custom_holidays(today).map { |holiday| format_custom_holiday(holiday) }

    hold_national_holiday? ? formatted_custom_holidays : (formatted_custom_holidays + formatted_event_holidays).sort
  end

  private

  def format_national_holiday(holiday)
    I18n.l(holiday.date, format: :with_weekday_and_holiday)
  end

  def format_custom_holiday(holiday)
    I18n.l(holiday.holiday_date, format: :long) + " #{holiday.description}"
  end
end
