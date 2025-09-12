# frozen_string_literal: true

require 'test_helper'
require 'supports/report_helper'

class UserStudyStreakTest < ActiveSupport::TestCase
  include ReportHelper

  setup do
    @user = users(:hajime)
    LearningTime.joins(:report).where(reports: { user_id: @user.id }).delete_all
    Report.where(user: @user, reported_on: Date.new(2024, 8, 1)..Time.zone.today).delete_all

    submitted_dates = %w[
      2024-08-07 2024-08-08 2024-08-09
      2024-08-15 2024-08-16
      2024-08-20 2024-08-21 2024-08-22
    ]
    submitted_dates.each do |date|
      create_report_data_with_learning_times(user: @user, on: date)
    end

    wip_report_dates = %w[2024-08-17 2024-08-23]
    wip_report_dates.each do |date|
      create_report_data_with_learning_times(user: @user, on: date, wip: true)
    end
    @reports = @user.reports_with_learning_times
    @study_streak = UserStudyStreak.new(@reports)
  end

  test 'streak_periods returns correct study_streak periods' do
    periods = @study_streak.send(:streak_periods)

    expected_periods = [
      { start_on: Date.parse('2024-08-07'), end_on: Date.parse('2024-08-09'), days: 3 },
      { start_on: Date.parse('2024-08-15'), end_on: Date.parse('2024-08-16'), days: 2 },
      { start_on: Date.parse('2024-08-20'), end_on: Date.parse('2024-08-22'), days: 3 }
    ]

    assert_equal expected_periods, periods
  end

  test 'longest_learning_streak returns the longest study_streak period (newest when tie)' do
    expected_longest = { start_on: Date.parse('2024-08-20'), end_on: Date.parse('2024-08-22'), days: 3 }
    assert_equal expected_longest[:start_on], @study_streak.longest_start_on
    assert_equal expected_longest[:end_on], @study_streak.longest_end_on
    assert_equal expected_longest[:days], @study_streak.longest_days
  end

  test 'longest_learning_streak returns nil when no learning days' do
    user_without_report = users(:nippounashi)
    no_streak = UserStudyStreak.new(user_without_report.reports_with_learning_times)

    assert_nil no_streak.longest_start_on
    assert_nil no_streak.longest_end_on
    assert_nil no_streak.longest_days
  end

  test 'current study_streak remains the latest period when today is not a learning day' do
    travel_to Date.parse('2024-08-25') do
      expected_current = { start_on: Date.parse('2024-08-20'), end_on: Date.parse('2024-08-22'), days: 3 }
      assert_equal expected_current[:start_on], @study_streak.current_start_on
      assert_equal expected_current[:end_on], @study_streak.current_end_on
      assert_equal expected_current[:days], @study_streak.current_days
    end
  end

  test 'includes wip report days when include_wip option is true' do
    study_streak = UserStudyStreak.new(@reports, include_wip: true)

    # WIP(2024-08-23)が反映されて連続日数が 4 日に延びる想定
    assert_equal Date.parse('2024-08-20'), study_streak.current_start_on
    assert_equal Date.parse('2024-08-23'), study_streak.current_end_on
    assert_equal 4, study_streak.current_days

    assert_equal Date.parse('2024-08-20'), study_streak.longest_start_on
    assert_equal Date.parse('2024-08-23'), study_streak.longest_end_on
    assert_equal 4, study_streak.longest_days

    # WIP(2024-08-17)も期間に含まれることを確認
    expected_periods = [
      { start_on: Date.parse('2024-08-07'), end_on: Date.parse('2024-08-09'), days: 3 },
      { start_on: Date.parse('2024-08-15'), end_on: Date.parse('2024-08-17'), days: 3 },
      { start_on: Date.parse('2024-08-20'), end_on: Date.parse('2024-08-23'), days: 4 }
    ]
    assert_equal expected_periods, study_streak.send(:streak_periods)
  end
end
