# frozen_string_literal: true

class UserStudyStreak
  attr_reader :current_start_on, :current_end_on, :current_days, :longest_start_on, :longest_end_on, :longest_days

  def initialize(reports, include_wip: false)
    @include_wip = include_wip
    @study_dates = report_dates(reports)

    current_period = find_latest_period
    longest_period = find_longest_period

    apply_current_period(current_period)
    apply_longest_period(longest_period)
  end

  private

  attr_reader :study_dates, :include_wip

  def report_dates(reports)
    reports = reports.not_wip unless include_wip
    reports.order(reported_on: :asc).pluck(:reported_on)
  end

  def streak_periods
    @streak_periods ||= begin
      return [] if study_dates.empty?

      study_dates.chunk_while { |a, b| b == a.next_day }.map do |chunk|
        { start_on: chunk.first, end_on: chunk.last, days: chunk.size }
      end
    end
  end

  def find_latest_period
    streak_periods.last
  end

  def find_longest_period
    return nil if streak_periods.empty?

    # days が最大、同点ならより新しい end_on を優先
    streak_periods.max_by { |p| [p[:days], p[:end_on]] }
  end

  def apply_current_period(hash)
    @current_start_on = hash ? hash[:start_on] : nil
    @current_end_on   = hash ? hash[:end_on] : nil
    @current_days     = hash ? hash[:days] : nil
  end

  def apply_longest_period(hash)
    @longest_start_on = hash ? hash[:start_on] : nil
    @longest_end_on   = hash ? hash[:end_on] : nil
    @longest_days     = hash ? hash[:days] : nil
  end
end
