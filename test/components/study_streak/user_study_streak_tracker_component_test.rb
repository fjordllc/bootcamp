# frozen_string_literal: true

require 'test_helper'
require 'supports/report_helper'

class StudyStreak::UserStudyStreakTrackerComponentTest < ViewComponent::TestCase
  include ReportHelper

  setup do
    travel_to Time.zone.local(2024, 9, 1)

    @user = users(:kimura)

    LearningTime.joins(:report).where(reports: { user_id: @user.id }).delete_all
    Report.where(user: @user, reported_on: Date.new(2024, 8, 1)..Time.zone.today).delete_all

    submitted_dates = %w[
      2024-08-07 2024-08-08 2024-08-09
      2024-08-20 2024-08-21 2024-08-22
    ]
    submitted_dates.each { |d| create_report_data_with_learning_times(user: @user, on: d) }
    reports = @user.reports_with_learning_times
    @study_streak = UserStudyStreak.new(reports)
  end

  teardown do
    travel_back
  end

  test 'renders current streak information' do
    render_inline(StudyStreak::UserStudyStreakTrackerComponent.new(study_streak: @study_streak))

    # 現在の連続学習日数と期間を表示する
    assert_selector '.streak-container'
    assert_text '日'
    assert_selector '.streak-item__number', text: '3', count: 2
    assert_selector '.streak-item__period', text: '08/20 〜 08/22'
  end

  test 'renders longest streak information (ties resolved by most recent)' do
    render_inline(StudyStreak::UserStudyStreakTrackerComponent.new(study_streak: @study_streak))

    # 最長連続日数も3日で、同率の場合は最新の期間を選ぶ
    assert_selector '.streak-item__number', text: '3'
    assert_selector '.streak-item__period', text: '08/20 〜 08/22'
  end

  test 'renders zero streak when no learning days' do
    user_without_learning = users(:hatsuno) # learning_times を含むレポートがないユーザー
    reports = user_without_learning.reports_with_learning_times
    study_streak = UserStudyStreak.new(reports, include_wip: false)
    render_inline(StudyStreak::UserStudyStreakTrackerComponent.new(study_streak:))

    # 0日を表示し、期間テキストは表示しない
    assert_selector '.streak-item__number', text: '0', count: 2

    # 期間要素は連続日数が1以上のときのみ条件付きでレンダリングされる
    refute_selector '.streak-item__period'
  end

  test 'structure has required CSS classes' do
    render_inline(StudyStreak::UserStudyStreakTrackerComponent.new(study_streak: @study_streak))

    assert_selector '.streak-container'
    assert_selector '.streak-item', count: 2
    assert_selector '.streak-item__content', count: 2
    assert_selector '.streak-item__number', count: 2
    assert_selector '.streak-item__unit', text: '日', count: 2
    assert_selector '.streak-item__label', count: 2
  end

  test 'date format follows "mm/dd 〜 mm/dd" pattern for the current year' do
    render_inline(StudyStreak::UserStudyStreakTrackerComponent.new(study_streak: @study_streak))

    assert_selector '.streak-item__period', text: '08/20 〜 08/22'
  end

  test 'date format follows "yyyy/mm/dd 〜 yyyy/mm/dd" pattern for a past year' do
    travel_to Time.zone.local(2025, 1, 1)
    render_inline(StudyStreak::UserStudyStreakTrackerComponent.new(study_streak: @study_streak))
    assert_selector '.streak-item__period', text: '2024/08/20 〜 2024/08/22'
  end

  test 'date format follows "yyyy/mm/dd 〜 yyyy/mm/dd" pattern across different years' do
    user = users(:machida)
    LearningTime.joins(:report).where(reports: { user_id: user.id }).delete_all
    Report.where(user:).delete_all
    submitted_dates = %w[2023-12-30 2023-12-31 2024-01-01 2024-01-02]
    submitted_dates.each { |date| create_report_data_with_learning_times(user:, on: date) }
    reports = user.reports_with_learning_times
    study_streak = UserStudyStreak.new(reports)

    render_inline(StudyStreak::UserStudyStreakTrackerComponent.new(study_streak:))
    assert_selector '.streak-item__period', text: '2023/12/30 〜 2024/01/02'
  end
end
