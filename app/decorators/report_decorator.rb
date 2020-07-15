# frozen_string_literal: true

module ReportDecorator
  def total_learning_time
    total_time = learning_times.inject(0) do |sum, learning_time|
      sum + learning_time.diff
    end

    total_minute = total_time / 60
    hour = (total_minute / 60).to_i
    minute = (total_minute % 60).round

    if minute == 0
      "#{hour}時間"
    else
      "#{hour}時間#{minute}分"
    end
  end

  def total_learning_minute
    total_time = learning_times.inject(0) do |sum, learning_time|
      sum + learning_time.diff
    end

    total_minute = (total_time / 60)
    if practices.size > 1
      average_minute_per_practice(total_minute)
    else
      total_minute
    end
  end

  def average_minute_per_practice(minute)
    minute / practices.size
  end

  def number
    serial_number == 1 ? "初日報" : serial_number
  end
end
