# frozen_string_literal: true

module CalendarMethods
  extend ActiveSupport::Concern

  def current_calendar_date(year_and_month)
    today = Date.current
    year, month = year_and_month ? year_and_month.split('-').map(&:to_i) : [today.year, today.month]
    params_date = Date.new(year, month)
    params_date.future? ? today : params_date
  end

  def calendar_with_reports(user, current_date)
    first_date_of_month = current_date.beginning_of_month
    last_date_of_month = current_date.end_of_month
    dates_of_month = (first_date_of_month..last_date_of_month)

    reports = user.reports.where(reported_on: dates_of_month, wip: false)
    reports_by_date = reports.index_by(&:reported_on)

    dates = dates_of_month.index_with { |_day| nil }

    dates.merge(reports_by_date).map do |date, report|
      { report:, date:, emotion: report&.emotion }
    end
  end
end
