# frozen_string_literal: true

class StudyStreak::UserStudyStreakTrackerComponent < ViewComponent::Base
  def initialize(user:, study_streak:)
    @user = user
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
    return '' if days.to_i.zero? || start_on.nil? || end_on.nil?

    start_date = start_on
    end_date = end_on
    if start_date.year == end_date.year
      "#{start_date.strftime('%b %-d')} - #{end_date.strftime('%b %-d')}"
    else
      "#{start_date.strftime('%b %-d, %Y')} - #{end_date.strftime('%b %-d, %Y')}"
    end
  end
end
