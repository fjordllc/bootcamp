# frozen_string_literal: true

require 'test_helper'
require 'supports/report_helper'

class StudyStreak::UserStudyStreakTrackerComponentTest < ViewComponent::TestCase
  include ReportHelper
  setup do
    @user = users(:kimura)

    LearningTime.joins(:report).where(reports: { user_id: @user.id }).delete_all
    Report.where(user: @user, reported_on: Date.new(2024, 8, 1)..Time.zone.today).delete_all

    %w[
      2024-08-07 2024-08-08 2024-08-09
      2024-08-20 2024-08-21 2024-08-22
    ].each { |d| create_report_data_with_learning_times(user: @user, on: d) }
    reports = @user.reports_with_learning_times
    @study_streak = UserStudyStreak.new(reports)
  end

  test 'renders current streak information' do
    render_inline(StudyStreak::UserStudyStreakTrackerComponent.new(user: @user, study_streak: @study_streak))

    # Shows current streak days and period
    assert_selector '.streak-container'
    assert_text 'days'
    assert_selector '.streak-item__number', text: '3', count: 2
    assert_selector '.streak-item__period', text: 'Aug 20 - Aug 22'
  end

  test 'renders longest streak information (ties resolved by most recent)' do
    render_inline(StudyStreak::UserStudyStreakTrackerComponent.new(user: @user, study_streak: @study_streak))

    # Longest streak should also be 3 days with the most recent period
    assert_selector '.streak-item__number', text: '3'
    assert_selector '.streak-item__period', text: 'Aug 20 - Aug 22'
  end

  test 'renders zero streak when no learning days' do
    user_without_learning = users(:hatsuno) # no report with learning_times
    reports = user_without_learning.reports_with_learning_times
    study_streak = UserStudyStreak.new(reports, include_wip: false)
    render_inline(StudyStreak::UserStudyStreakTrackerComponent.new(user: user_without_learning, study_streak:))

    # Shows 0 days, and no period text (empty)
    assert_selector '.streak-item__number', text: '0', count: 2

    # period element is conditionally rendered only when positive days
    refute_selector '.streak-item__period'
  end

  test 'structure has required CSS classes' do
    render_inline(StudyStreak::UserStudyStreakTrackerComponent.new(user: @user, study_streak: @study_streak))

    assert_selector '.streak-container'
    assert_selector '.streak-container__item', count: 2
    assert_selector '.streak-item', count: 2
    assert_selector '.streak-item__content', count: 2
    assert_selector '.streak-item__number', count: 2
    assert_selector '.streak-item__unit', text: 'days', count: 2
    assert_selector '.streak-item__label', count: 2
  end

  test 'date format follows "Aug d - Aug d" pattern for same year' do
    render_inline(StudyStreak::UserStudyStreakTrackerComponent.new(user: @user, study_streak: @study_streak))

    assert_selector '.streak-item__period', text: /Aug \d{1,2} - Aug \d{1,2}/
  end
end
