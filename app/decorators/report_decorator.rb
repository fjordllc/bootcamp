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

  def decide_which_report
    if serial_number == 1
      "初日報"
    else
      "#{serial_number}"
    end
  end

  # def first_report?
  #   serial_number == 1
  # end

  # def important?
  #   serial_number < 6 ? "is-important" : ""
  # end
end
