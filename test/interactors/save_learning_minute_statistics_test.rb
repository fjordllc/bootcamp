# frozen_string_literal: true

require 'test_helper'

class SaveLearningMinuteStatisticsTest < ActiveSupport::TestCase
  test 'call' do
    LearningMinuteStatistic.delete_all
    assert LearningMinuteStatistic.count.zero?

    SaveLearningMinuteStatistics.call

    practice_ids = Practice.joins(:reports).merge(Report.not_wip).distinct.pluck(:id)
    assert_equal practice_ids.size, LearningMinuteStatistic.count
  end
end
