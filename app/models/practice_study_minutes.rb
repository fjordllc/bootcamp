# frozen_string_literal: true

class PracticeStudyMinutes
  def initialize(practice)
    @practice = practice
  end

  def learning_minute_per_user
    user_id = 0
    learning_minute_list = []

    @practice.reports.not_wip.order('user_id asc').each do |report|
      if user_id == report.user_id
        sum_same_user = learning_minute_list.last + total_learning_minute(report)
        learning_minute_list.pop
        learning_minute_list << sum_same_user
      else
        learning_minute_list << total_learning_minute(report)
        user_id = report.user_id
      end
    end
    learning_minute_list.sort!
  end

  def convert_to_hour_minute(learning_minute_statistic)
    converted_hour = learning_minute_statistic / 60
    converted_minute = (learning_minute_statistic % 60).round
    if converted_minute.zero?
      "#{converted_hour}時間"
    else
      "#{converted_hour}時間#{converted_minute}分"
    end
  end

  private

  def total_learning_minute(report)
    total_time = report.learning_times.inject(0) do |sum, learning_time|
      sum + learning_time.diff
    end

    total_minute = (total_time / 60)
    if report.practices.size > 1
      average_minute_per_practice(total_minute, report.practices.size)
    else
      total_minute
    end
  end

  def average_minute_per_practice(minute, size)
    minute / size
  end
end
