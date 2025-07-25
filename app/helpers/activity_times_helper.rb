# frozen_string_literal: true

module ActivityTimesHelper
  HOURS_PER_DAY = 24
  DAYS_PER_WEEK = 7

  def format_time_range(hour)
    hour_int = hour.to_i
    next_hour = (hour_int + 1) % HOURS_PER_DAY
    "#{hour_int}:00-#{next_hour}:00"
  end

  def day_names_with_suffix
    day_of_the_week.map { |d| "#{d}曜日" }
  end

  def clamp_day_index(day_of_week)
    day_of_week.to_i.clamp(0, DAYS_PER_WEEK - 1)
  end

  def clamp_hour(hour)
    hour.to_i.clamp(0, HOURS_PER_DAY - 1)
  end
end
