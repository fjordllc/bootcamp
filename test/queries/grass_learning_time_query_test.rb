# frozen_string_literal: true

require 'test_helper'

class GrassLearningTimeQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:sotugyou)

    # 年末（2024-12-31）と年始（2025-01-01）にまたがる学習記録を作成
    @report1 = Report.create!(
      user: @user,
      reported_on: Date.new(2024, 12, 31),
      title: '年末の記録',
      description: '年末に勉強した内容',
      emotion: :happy
    )

    LearningTime.create!(
      report: @report1,
      started_at: Time.zone.local(2024, 12, 31, 10),
      finished_at: Time.zone.local(2024, 12, 31, 11)
    )

    @report2 = Report.create!(
      user: @user,
      reported_on: Date.new(2025, 1, 1),
      title: '年始の記録',
      description: '年始に勉強した内容',
      emotion: :happy
    )

    LearningTime.create!(
      report: @report2,
      started_at: Time.zone.local(2025, 1, 1, 13),
      finished_at: Time.zone.local(2025, 1, 1, 18)
    )
  end

  test 'includes learning data across year boundary' do
    end_date = Date.new(2025, 1, 2)
    results = GrassLearningTimeQuery.call(@user, end_date)

    # 結果の中に該当日が含まれていて、それぞれのvelocityが正しいかを確認
    result_by_date = results.index_by { |r| r.date.to_date }

    assert_includes result_by_date, Date.new(2024, 12, 31)
    assert_equal 1, result_by_date[Date.new(2024, 12, 31)].velocity

    assert_includes result_by_date, Date.new(2025, 1, 1)
    assert_equal 3, result_by_date[Date.new(2025, 1, 1)].velocity
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

    start_date = Date.new(2025, 1, 3)
    end_date = Date.new(2025, 1, 3)
    results = GrassLearningTimeQuery.new(@user, end_date, LearningTime.all, start_date:).call
    result_by_date = results.index_by { |r| r.date.to_date }

    assert_equal 3, result_by_date[Date.new(2025, 1, 3)].velocity
  end

  test 'returns velocity 0 for dates with no learning data' do
    # 2025-01-０4 に何も記録しない
    start_date = Date.new(2025, 1, 4)
    end_date = Date.new(2025, 1, 4)

    results = GrassLearningTimeQuery.new(@user, end_date, LearningTime.all, start_date:).call
    result_by_date = results.index_by { |r| r.date.to_date }

    assert_equal 0, result_by_date[Date.new(2025, 1, 4)].velocity
  end

  test 'includes learning data across month boundary' do
    report1 = Report.create!(
      user: @user,
      reported_on: Date.new(2025, 1, 31),
      title: '1月末の記録',
      description: '月末の勉強',
      emotion: :happy
    )

    LearningTime.create!(
      report: report1,
      started_at: Time.zone.local(2025, 1, 31, 10),
      finished_at: Time.zone.local(2025, 1, 31, 12)
    )

    report2 = Report.create!(
      user: @user,
      reported_on: Date.new(2025, 2, 1),
      title: '2月初の記録',
      description: '月初の勉強',
      emotion: :happy
    )

    LearningTime.create!(
      report: report2,
      started_at: Time.zone.local(2025, 2, 1, 14),
      finished_at: Time.zone.local(2025, 2, 1, 17)
    )

    start_date = Date.new(2025, 1, 31)
    end_date = Date.new(2025, 2, 1)

    results = GrassLearningTimeQuery.new(@user, end_date, LearningTime.all, start_date:).call
    result_by_date = results.index_by { |r| r.date.to_date }

    assert_equal 1, result_by_date[Date.new(2025, 1, 31)].velocity
    assert_equal 2, result_by_date[Date.new(2025, 2, 1)].velocity
  end
end
