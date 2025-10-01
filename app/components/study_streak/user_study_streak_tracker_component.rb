# frozen_string_literal: true

class StudyStreak::UserStudyStreakTrackerComponent < ViewComponent::Base
  def initialize(study_streak:)
    @study_streak = study_streak
  end

  def current_streak?
    @study_streak.current_days.to_i.positive?
  end

  def longest_streak?
    @study_streak.longest_days.to_i.positive?
  end

  def current_streak_days
    @study_streak.current_days.to_i
  end

  def longest_streak_days
    @study_streak.longest_days.to_i
  end

  def current_streak_period
    format_period(
      days: @study_streak.current_days,
      start_on: @study_streak.current_start_on,
      end_on: @study_streak.current_end_on
    )
  end

  def longest_streak_period
    format_period(
      days: @study_streak.longest_days,
      start_on: @study_streak.longest_start_on,
      end_on: @study_streak.longest_end_on
    )
  end

  private

  def format_period(days:, start_on:, end_on:)
    return '' if days.to_i.zero? || start_on.blank? || end_on.blank?

    if start_on.year == end_on.year
      "#{start_on.strftime('%m/%d')} 〜 #{end_on.strftime('%m/%d')}"
    else
      "#{start_on.strftime('%Y/%m/%d')} 〜 #{end_on.strftime('%Y/%m/%d')}"
    end
  end
end
