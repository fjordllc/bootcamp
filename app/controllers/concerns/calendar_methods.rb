# frozen_string_literal: true

module CalendarMethods
  extend ActiveSupport::Concern

  def current_calendar_date(year, month)
    current_year = year || Time.zone.now.year
    current_month = month || Time.zone.now.month
    Date.new(current_year.to_i, current_month.to_i)
  end

  def calendars_with_reports(user, date)
    first_date_of_month = date.beginning_of_month
    last_date_of_month = date.end_of_month
    dates_of_month = (first_date_of_month..last_date_of_month)

    reports = user.reports.where(reported_on: dates_of_month, wip: false)
    emotions = reports.index_by(&:reported_on)

    dates = dates_of_month.index_with { |_day| nil }

    dates.merge(emotions)
         .to_a
         .map { |set| [report: set[1], date: set[0], emotion: set[1]&.emotion] }
         .flatten
  end
end
