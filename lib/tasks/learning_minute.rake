# frozen_string_literal: true

namespace :learning_minute do
  desc "学習時間の統計をDB保存する"
  task :statistics do
    practices = Practice.all
    practices.each do |practice|
      practice_id = practice.id
      learning_minute_list = practice_learning_minute_per_user(practice)

      if learning_minute_list.sum > 0
        average_learning_minute = average_learning_minute(learning_minute_list)
        median_learning_minute = median_learning_minute(learning_minute_list)
        find_or_initialize(practice_id, average_learning_minute, median_learning_minute)
      end
    end
  end

  def practice_learning_minute_per_user(practice)
    user_id = 0
    learning_minute_list = []

    practice.reports.not_wip.order("user_id asc").each do |report|
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

  def average_learning_minute(learning_minute_list)
    learning_minute_list.sum.fdiv(learning_minute_list.size)
  end

  def median_learning_minute(minute_list)
    center_index = ((minute_list.size - 1) / 2).floor
    if minute_list.size.even?
      median_learning_minute = (minute_list[center_index] + minute_list[center_index + 1]) / 2
    else
      median_learning_minute = (minute_list[center_index])
    end
  end

  def find_or_initialize(practice_id, average, median)
    learning_minute_statistic = LearningMinuteStatistic.find_or_initialize_by(practice_id: practice_id)
    learning_minute_statistic.update_attributes(
      average: average,
      median: median
    )
  end
end
