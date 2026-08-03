# frozen_string_literal: true

class SaveLearningMinuteStatistics
  include Interactor

  def call
    Practice.all.find_each do |practice|
      practice_id = practice.id
      learning_minute_list = practice.learning_minute_per_user

      if learning_minute_list.sum.positive?
        average_learning_minute = practice.average_learning_minute(learning_minute_list)
        median_learning_minute = practice.median_learning_minute(learning_minute_list)
        practice.save_statistic(practice_id, average_learning_minute, median_learning_minute)
      end
    end
  end
end
