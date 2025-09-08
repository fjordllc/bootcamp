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

  test 'returns series from the Sunday of end_date.prev_year to end_date with correct length' do
    end_date = Date.new(2025, 1, 3)
    results = GrassLearningTimeQuery.new(@user, end_date, LearningTime.all).call
    dates = results.map { |r| r.date.to_date }

    expected_start_date = end_date.prev_year.sunday
    assert_equal expected_start_date, dates.first
    expected_length = (end_date - expected_start_date).to_i + 1
    assert_equal expected_length, dates.size
  end

  test 'velocity is 1 when total_hour is exactly 2' do
    report = Report.create!(
      user: @user,
      reported_on: Date.new(2025, 1, 5),
      title: '2時間テスト',
      description: 'テスト用ダミー内容',
      emotion: :happy
    )
    LearningTime.create!(
      report:,
      started_at: Time.zone.local(2025, 1, 5, 10),
      finished_at: Time.zone.local(2025, 1, 5, 12)
    )

    results = GrassLearningTimeQuery.new(@user, Date.new(2025, 1, 5)).call
    result_by_date = results.index_by { |r| r.date.to_date }

    assert_equal 1, result_by_date[Date.new(2025, 1, 5)].velocity
  end

  test 'velocity is 2 when total_hour is exactly 4' do
    report = Report.create!(
      user: @user,
      reported_on: Date.new(2025, 1, 6),
      title: '4時間テスト',
      description: 'テスト用ダミー内容',
      emotion: :happy
    )
    LearningTime.create!(
      report:,
      started_at: Time.zone.local(2025, 1, 6, 9),
      finished_at: Time.zone.local(2025, 1, 6, 13)
    )

    results = GrassLearningTimeQuery.new(@user, Date.new(2025, 1, 6)).call
    result_by_date = results.index_by { |r| r.date.to_date }

    assert_equal 2, result_by_date[Date.new(2025, 1, 6)].velocity
  end

  test 'velocity is 3 when total_hour is exactly 6' do
    report = Report.create!(
      user: @user,
      reported_on: Date.new(2025, 1, 7),
      title: '6時間テスト',
      description: 'テスト用ダミー内容',
      emotion: :happy
    )
    LearningTime.create!(
      report:,
      started_at: Time.zone.local(2025, 1, 7, 8),
      finished_at: Time.zone.local(2025, 1, 7, 14)
    )

    results = GrassLearningTimeQuery.new(@user, Date.new(2025, 1, 7)).call
    result_by_date = results.index_by { |r| r.date.to_date }

    assert_equal 3, result_by_date[Date.new(2025, 1, 7)].velocity
  end
end
