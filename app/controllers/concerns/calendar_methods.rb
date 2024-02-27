# frozen_string_literal: true

module CalendarMethods
  extend ActiveSupport::Concern

  def current_calendar_date(year_and_month)
    today = Date.current
    year, month = year_and_month ? year_and_month.split('-').map(&:to_i) : [today.year, today.month]
    params_date = Date.new(year, month)
    params_date.future? ? today : params_date
  end

  def calendar_with_reports(user, date)
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
