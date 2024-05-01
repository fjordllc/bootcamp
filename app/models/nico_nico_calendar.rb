# frozen_string_literal: true

class NicoNicoCalendar
  class << self
    def current_date(year_and_month)
      today = Date.current
      year, month = year_and_month ? year_and_month.split('-').map(&:to_i) : [today.year, today.month]
      params_date = Date.new(year, month)
      params_date.future? ? today : params_date
    end

    def with_reports(user, current_date)
      reports_by_date = user.reports.where(reported_on: dates_of_month(current_date), wip: false).index_by(&:reported_on)
      dates_of_month(current_date).index_with { |_day| nil }.merge(reports_by_date).map do |date, report|
        { report:, date:, emotion: report&.emotion }
      end
    end

    private

    def dates_of_month(date)
      first_date_of_month = date.beginning_of_month
      last_date_of_month = date.end_of_month
      (first_date_of_month..last_date_of_month)
    end
  end
end
