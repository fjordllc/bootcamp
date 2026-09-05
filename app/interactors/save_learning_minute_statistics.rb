# frozen_string_literal: true

class SaveLearningMinuteStatistics
  include Interactor

  def call
    Practice.all.find_each do |practice|
      learning_minute_list = practice.learning_minute_per_user

      next unless learning_minute_list.sum.positive?

      average = average_learning_minute(learning_minute_list)
      median = median_learning_minute(learning_minute_list)
      save_statistic(practice.id, average, median)
    end
  end

  private

  def average_learning_minute(learning_minute_list)
    learning_minute_list.sum.fdiv(learning_minute_list.size)
  end

  def median_learning_minute(minute_list)
    center_index = ((minute_list.size - 1) / 2).floor
    if minute_list.size.even?
      (minute_list[center_index] + minute_list[center_index + 1]) / 2
    else
      minute_list[center_index]
    end
  end

  def save_statistic(practice_id, average, median)
    learning_minute_statistic = LearningMinuteStatistic.find_or_initialize_by(practice_id:)
    learning_minute_statistic.update(
      average:,
      median:
    )
  end
end
