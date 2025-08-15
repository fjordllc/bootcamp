# frozen_string_literal: true

JAPANESE_WEEKDAYS = %w[日 月 火 水 木 金 土].freeze

module TimeRangeHelper
  def time_range(time)
    start_hour = time.change(min: 0, sec: 0)
    end_hour = start_hour + 1.hour

    "(#{JAPANESE_WEEKDAYS[time.wday]}) #{start_hour.strftime('%H:%M')} 〜 #{end_hour.strftime('%H:%M')}"
  end
end
