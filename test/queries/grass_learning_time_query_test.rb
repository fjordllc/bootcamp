# frozen_string_literal: true

require 'test_helper'

class GrassLearningTimeQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:sotugyou)
  end

  test 'calculates velocity based on total learning time for the same day' do
    report = Report.create!(
      user: @user,
      reported_on: Date.new(2025, 1, 3),
      title: '同日の複数記録',
      description: '午前と午後に勉強',
      emotion: :happy
    )

    LearningTime.create!(
      report:,
      started_at: Time.zone.local(2025, 1, 3, 9),
      finished_at: Time.zone.local(2025, 1, 3, 11)
    )

    LearningTime.create!(
      report:,
      started_at: Time.zone.local(2025, 1, 3, 13),
      finished_at: Time.zone.local(2025, 1, 3, 16)
    )

    end_date = Date.new(2025, 1, 3)
    results = GrassLearningTimeQuery.new(@user, end_date, LearningTime.all).call
    result_by_date = results.index_by { |r| r.date.to_date }

    assert_equal 3, result_by_date[Date.new(2025, 1, 3)].velocity
  end

  test 'returns velocity 0 for dates with no learning data' do
    # 2025-01-０4 に何も記録しない
    end_date = Date.new(2025, 1, 4)
    results = GrassLearningTimeQuery.new(@user, end_date, LearningTime.all).call
    result_by_date = results.index_by { |r| r.date.to_date }

    assert_equal 0, result_by_date[Date.new(2025, 1, 4)].velocity
  end

  test 'returns series with correct start_date and length' do
    # デフォルト start_date（end_date.prev_year.sunday）から end_date までの series の開始日と件数が正しいことを確認
    end_date = Date.new(2025, 1, 3)
    results = GrassLearningTimeQuery.new(@user, end_date, LearningTime.all).call
    dates = results.map { |r| r.date.to_date }

    expected_start_date = end_date.prev_year.sunday
    assert_equal expected_start_date, dates.first
    expected_length = (end_date - expected_start_date).to_i + 1
    assert_equal expected_length, dates.size
  end
end
