# frozen_string_literal: true

class StudyStreakStudyStreakTrackerComponentPreview < ViewComponent::Preview
  def default
    study_streak = OpenStruct.new(
      current_days: 5,
      longest_days: 14,
      current_start_on: 5.days.ago.to_date,
      current_end_on: Date.current,
      longest_start_on: 30.days.ago.to_date,
      longest_end_on: 16.days.ago.to_date
    )

    render(StudyStreak::StudyStreakTrackerComponent.new(study_streak: study_streak))
  end

  def no_streak
    study_streak = OpenStruct.new(
      current_days: 0,
      longest_days: 0,
      current_start_on: nil,
      current_end_on: nil,
      longest_start_on: nil,
      longest_end_on: nil
    )

    render(StudyStreak::StudyStreakTrackerComponent.new(study_streak: study_streak))
  end

  def long_streak
    study_streak = OpenStruct.new(
      current_days: 100,
      longest_days: 100,
      current_start_on: 100.days.ago.to_date,
      current_end_on: Date.current,
      longest_start_on: 100.days.ago.to_date,
      longest_end_on: Date.current
    )

    render(StudyStreak::StudyStreakTrackerComponent.new(study_streak: study_streak))
  end
end
