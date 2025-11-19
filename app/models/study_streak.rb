# frozen_string_literal: true

class StudyStreak
  attr_reader :current_start_on, :current_end_on, :current_days, :longest_start_on, :longest_end_on, :longest_days

  def initialize(reports, include_wip: false)
    @include_wip = include_wip
    @study_dates = report_dates(reports)

    current_period = streak_periods.last
    @current_start_on = current_period&.[](:start_on)
    @current_end_on   = current_period&.[](:end_on)
    @current_days     = current_period&.[](:days)

    longest_period = find_longest_period
    @longest_start_on = longest_period&.[](:start_on)
    @longest_end_on   = longest_period&.[](:end_on)
    @longest_days     = longest_period&.[](:days)
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

  def find_longest_period
    # days が最大、同点ならより新しい end_on を優先
    streak_periods.max_by { |p| [p[:days], p[:end_on]] }
  end
end
